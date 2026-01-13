function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	if game.Us == nil then
		UI.Alert("You can't do anything as a spectator.")
		return
	end

	local Advancements = Mod.Settings.Advancements

	-- Data we get from server
	UnlockedUpgrades = {}
	GetUnlockedFromServer(game)
	UpgradePoints = {}
	GetPlayerPointsFromServer(game, Advancements)

	-- UI setup
	---@type UI
	UI = UI
	local advancementView = GetDefaultView(Advancements)
	setMaxSize(550, 650)
	setScrollable(false, true)

	local verticalMainLayout = UI.CreateVerticalLayoutGroup(rootParent)
	local advancmentButtons = UI.CreateHorizontalLayoutGroup(verticalMainLayout)
	local advancmentUpgradeArea = UI.CreateVerticalLayoutGroup(verticalMainLayout)

	-- Track created upgrade UI elements for destruction later
	local upgradeUIElements = {}



	local function DestroyOldAdvancmentUpgrades()
		for i = #upgradeUIElements, 1, -1 do
			UI.Destroy(upgradeUIElements[i])
			upgradeUIElements[i] = nil
		end
	end

	function UpdateView()
		DestroyOldAdvancmentUpgrades()

		print("Selected Advancment: " .. advancementView)

		local upgrades = Advancements[advancementView].Upgrades

		for _, upgrade in ipairs(upgrades) do
			local line = UI.CreateHorizontalLayoutGroup(advancmentUpgradeArea)
			table.insert(upgradeUIElements, line)

			local btn = UI.CreateButton(line).SetText(upgrade.Name)

			if UnlockedUpgrades[upgrade.UID] then
				btn.SetInteractable(false).SetColor("#00FF00")
			else
				local isAffordable = upgrade.Cost <= UpgradePoints[advancementView]
				btn.SetInteractable(isAffordable).SetColor(isAffordable and "#FFFFFF" or "#FF0000")
			end

			table.insert(upgradeUIElements, btn)
		end
	end

	local function SelectAdvancment(advancment)
		advancementView = advancment
		UpdateView()
	end

	-- Buttons
	PointsButton = UI.CreateButton(advancmentButtons)
		.SetInteractable(false)
		.SetText(UpgradePoints[advancementView] ..
			" Points")


	if Advancements.Economy.Enabled then
		UI.CreateButton(advancmentButtons)
			.SetText("Economy")
			.SetColor(Advancements.Economy.Color)
			.SetOnClick(function()
				SelectAdvancment("Economy")
			end)
	end

	if Advancements.Culture.Enabled then
		UI.CreateButton(advancmentButtons)
			.SetText("Culture")
			.SetColor(Advancements.Culture.Color)
			.SetOnClick(function()
				SelectAdvancment("Culture")
			end)
	end

	if Advancements.Armies.Enabled then
		UI.CreateButton(advancmentButtons)
			.SetText("Armies")
			.SetColor(Advancements.Armies.Color)
			.SetOnClick(function()
				SelectAdvancment("Armies")
			end)
	end

	-- Refresh button to manually get updated data from server
	UI.CreateButton(advancmentButtons).SetText("Refresh data").SetOnClick(function()
		-- View is updated by the callbacks
		GetPlayerPointsFromServer(game, Advancements)
		GetUnlockedFromServer(game)
	end)

	-- Show default view
	UpdateView()
end

function GetUnlockedFromServer(game)
	local unlockPayload = { Type = "GetUnlocked" }
	game.SendGameCustomMessage("Getting unlocked advancements", unlockPayload, function(returnData)
		UpdateAdvancmentData(returnData)
	end)
end

function UpdateAdvancmentData(returnData)
	if not returnData.Success then
		print(returnData.Message)
		UI.Alert(returnData.Message)
		return
	end
	print("Received unlocked upgrades data.")
	UnlockedUpgrades = returnData
	UpdateView()
end

function GetPlayerPointsFromServer(game, Advancment)
	-- Set points to zero, in case server request fails
	for advancmentName, advancment in pairs(Advancment) do
		if advancment.Enabled then
			UpgradePoints[advancmentName] = 0
		end
		UpgradePoints[advancmentName] = 0
	end

	local pointsPayload = { Type = "GetPlayerPoints" }
	game.SendGameCustomMessage("Getting advancment points", pointsPayload, function(returnData)
		UpdatePlayerPoints(returnData, Advancment)
	end)
end

function UpdatePlayerPoints(returnData, Advancment)
	if not returnData.Success then
		print(returnData.Message)
		UI.Alert(returnData.Message)
		return
	end

	for advancmentName, advancment in pairs(Advancment) do
		if advancment.Enabled then
			UpgradePoints[advancmentName] = returnData.Points[advancmentName] or 0
			print("Received " .. UpgradePoints[advancmentName] .. " points for " .. advancmentName)
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
