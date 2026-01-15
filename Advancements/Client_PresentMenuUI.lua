local ClientState = {
	UnlockedUpgrades = {},
	UpgradePoints = {}
}

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	local uiReady = false

	if game.Us == nil then
		UI.Alert("You can't do anything as a spectator.")
		return
	end

	local Advancements = Mod.Settings.Advancements

	GetUnlockedFromServer(game)
	GetPlayerPointsFromServer(game)

	-- UI setup
	---@type UI
	UI = UI
	local advancementView = GetDefaultView(Advancements)
	setMaxSize(550, 650)
	setScrollable(false, true)

	local verticalMainLayout = UI.CreateVerticalLayoutGroup(rootParent)
	local advancementButtons = UI.CreateHorizontalLayoutGroup(verticalMainLayout)
	local advancementUpgradeArea = UI.CreateVerticalLayoutGroup(verticalMainLayout)

	-- Track created upgrade UI elements for destruction later
	local upgradeUIElements = {}



	local function DestroyOldAdvancmentUpgrades()
		for i = #upgradeUIElements, 1, -1 do
			UI.Destroy(upgradeUIElements[i])
			upgradeUIElements[i] = nil
		end
	end

	function UpdateView()
		if not uiReady then
			print("ui not ready!")
			return
		end
		DestroyOldAdvancmentUpgrades()

		local UpgradePoints = ClientState.UpgradePoints
		local points = UpgradePoints[advancementView] or 0

		print("Selected Advancment: " .. advancementView)
		print("points " .. points)

		PointsButton.SetText(points .. " Points")

		local upgrades = Advancements[advancementView].Upgrades

		for _, upgrade in ipairs(upgrades) do
			local line = UI.CreateHorizontalLayoutGroup(advancementUpgradeArea)
			table.insert(upgradeUIElements, line)

			local upgradebtn = UI.CreateButton(line).SetText(upgrade.Name)

			if ClientState.UnlockedUpgrades[upgrade.UID] then
				upgradebtn.SetInteractable(false).SetColor("#00FF00")
			else
				local isAffordable = upgrade.Cost <= points
				upgradebtn.SetInteractable(isAffordable).SetColor(isAffordable and "#FFFFFF" or "#FF0000")
			end
			local buyButton = UI.CreateButton(line).SetText("Unlock (" .. upgrade.Cost .. " pts)").SetOnClick(function()
				UnlockUpgrade(upgrade.UID, advancementView, game)
			end)
			local helpButton = UI.CreateButton(line).SetText("?").SetOnClick
				(function()
					UI.Alert(upgrade.Description)
				end)

			table.insert(upgradeUIElements, upgradebtn)
			table.insert(upgradeUIElements, buyButton)
			table.insert(upgradeUIElements, helpButton)
		end
	end

	local function SelectAdvancment(advancment)
		advancementView = advancment
		UpdateView()
	end

	print("advancementButtons")
	print(advancementButtons)
	-- Buttons
	PointsButton = UI.CreateButton(advancementButtons)
		.SetInteractable(false)
		.SetText("0 Points")


	if Advancements.Economy.Enabled then
		UI.CreateButton(advancementButtons)
			.SetText("Economy")
			.SetColor(Advancements.Economy.Color)
			.SetOnClick(function()
				SelectAdvancment("Economy")
			end)
	end

	if Advancements.Culture.Enabled then
		UI.CreateButton(advancementButtons)
			.SetText("Culture")
			.SetColor(Advancements.Culture.Color)
			.SetOnClick(function()
				SelectAdvancment("Culture")
			end)
	end

	if Advancements.Armies.Enabled then
		UI.CreateButton(advancementButtons)
			.SetText("Armies")
			.SetColor(Advancements.Armies.Color)
			.SetOnClick(function()
				SelectAdvancment("Armies")
			end)
	end

	-- Refresh button to manually get updated data from server
	UI.CreateButton(advancementButtons).SetText("Refresh data").SetOnClick(function()
		-- View is updated by the callbacks
		GetPlayerPointsFromServer(game)
		GetUnlockedFromServer(game)
	end)

	uiReady = true
	-- Show default view
	UpdateView()
end

function UnlockUpgrade(upgradeUID, advancementView, game)
	local unlockPayload = { Type = "UnlockUpgrade", UpgradeUID = upgradeUID, AdvancementName = advancementView }
	game.SendGameCustomMessage("Unlocking upgrade", unlockPayload, function(returnData)
		UpdateUnlockUpgrade(returnData)
	end)
end

function UpdateUnlockUpgrade(returnData)
	if returnData.Success then
		-- todo this will not update the state of the UI ( points and unlocked )
		ClientState.UnlockedUpgrades[returnData.UpgradeUID] = true
		UpdateView()
		UI.Alert(returnData.Message)
	else
		UI.Alert(returnData.Message)
	end
end

function GetUnlockedFromServer(game)
	local getUnlockPayload = { Type = "GetUnlocked" }
	game.SendGameCustomMessage("Getting unlocked advancements", getUnlockPayload, function(returnData)
		UpdateAdvancementsData(returnData)
	end)
end

function UpdateAdvancementsData(returnData)
	if not returnData.Success then
		print(returnData.Message)
		UI.Alert(returnData.Message)
		return
	end
	print("Received unlocked upgrades data.")
	ClientState.UnlockedUpgrades = returnData.UnlockedUpgrades
	UpdateView()
end

function GetPlayerPointsFromServer(game)
	local pointsPayload = { Type = "GetPlayerPoints" }
	game.SendGameCustomMessage("Getting advancements points", pointsPayload, function(returnData)
		UpdatePlayerPoints(returnData)
	end)
end

function UpdatePlayerPoints(returnData)
	if not returnData.Success then
		print(returnData.Message)
		UI.Alert(returnData.Message)
		return
	end
	local Advancements = Mod.Settings.Advancements
	for advancementsName, advancements in pairs(Advancements) do
		if advancements.Enabled then
			ClientState.UpgradePoints[advancementsName] = returnData.Points[advancementsName] or 0
			print("Received " .. ClientState.UpgradePoints[advancementsName] .. " points for " .. advancementsName)
		end
	end
	UpdateView()
end

function GetDefaultView(Advancements)
	if Advancements.Economy.Enabled then
		return "Economy"
	elseif Advancements.Culture.Enabled then
		return "Culture"
	elseif Advancements.Armies.Enabled then
		return "Armies"
	else
		UI.Alert("No Advancments are enabled in the mod settings. This should not be possible.")
		return ""
	end
end
