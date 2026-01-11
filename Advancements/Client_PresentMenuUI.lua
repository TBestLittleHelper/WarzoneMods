function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	if game.Us == nil then
		UI.Alert("You can't do anything as a spectator.")
		return
	end

	UnlockedUpgrades = {}
	GetUnlockedFromServer(game)


	setMaxSize(550, 650)
	setScrollable(false, true)

	local Advancements = Mod.Settings.Advancments

	---@type UI
	UI = UI

	local verticalMainLayout = UI.CreateVerticalLayoutGroup(rootParent)
	local advancmentButtons = UI.CreateHorizontalLayoutGroup(verticalMainLayout)
	local advancmentUpgradeArea = UI.CreateVerticalLayoutGroup(verticalMainLayout)

	-- Track created upgrade UI elements for destruction later
	local upgradeUIElements = {}

	UpgradePoints = {}
	GetPlayerPointsFromServer(game)

	local function DestroyOldAdvancmentUpgrades()
		for i = #upgradeUIElements, 1, -1 do
			UI.Destroy(upgradeUIElements[i])
			upgradeUIElements[i] = nil
		end
	end

	local function SelectAdvancment(advancment, upgrades)
		DestroyOldAdvancmentUpgrades()

		print("Selected Advancment: " .. advancment)

		for _, upgrade in ipairs(upgrades) do
			local line = UI.CreateHorizontalLayoutGroup(advancmentUpgradeArea)
			table.insert(upgradeUIElements, line)

			local btn = UI.CreateButton(line).SetText(upgrade.Name)

			if UnlockedUpgrades[upgrade.UID] then
				btn.SetInteractable(false).SetColor("#00FF00")
			else
				local isAffordable = upgrade.Cost <= UpgradePoints[advancment]
				btn.SetInteractable(isAffordable).SetColor(isAffordable and "#FFFFFF" or "#FF0000")
			end

			table.insert(upgradeUIElements, btn)
		end
	end

	-- Buttons
	UI.CreateButton(advancmentButtons).SetInteractable(false).SetText(UpgradePoints .. " Points")


	if Advancements.Economy.Enabled then
		UI.CreateButton(advancmentButtons)
			.SetText("Economy")
			.SetColor(Advancements.Economy.Color)
			.SetOnClick(function()
				SelectAdvancment("Economy", Advancements.Economy.Upgrades)
			end)
	end

	if Advancements.Culture.Enabled then
		UI.CreateButton(advancmentButtons)
			.SetText("Culture")
			.SetColor(Advancements.Culture.Color)
			.SetOnClick(function()
				SelectAdvancment("Culture", Advancements.Culture.Upgrades)
			end)
	end

	if Advancements.Armies.Enabled then
		UI.CreateButton(advancmentButtons)
			.SetText("Armies")
			.SetColor(Advancements.Armies.Color)
			.SetOnClick(function()
				SelectAdvancment("Armies", Advancements.Armies.Upgrades)
			end)
	end

	-- Refresh button to manually get updated data from server
	UI.CreateButton(advancmentButtons).SetText("Refresh data").SetOnClick(function()
		GetPlayerPointsFromServer(game)
		GetUnlockedFromServer(game)
		DestroyOldAdvancmentUpgrades()
	end)
end

function GetUnlockedFromServer(game)
	local unlockPayload = { Type = "GetUnlocked" }
	game.SendGameCustomMessage("Getting unlocked advancments", unlockPayload, function(returnData)
		UpdateAdvancmentData(returnData)
	end)
end

function UpdateAdvancmentData(returnData)
	print(returnData)
	if not returnData.Success then
		print(returnData.Message)
		UI.Alert(returnData.Message)
		return
	end
	print("Received unlocked upgrades data.")
	UnlockedUpgrades = returnData
end

function GetPlayerPointsFromServer(game)
	-- Set points to zero, in case server request fails
	for advancmentName, advancment in pairs(Mod.Settings.Advancements) do
		if advancment.Enabled then
			UpgradePoints[advancmentName] = 0
		end
		UpgradePoints[advancmentName] = 0
	end

	local pointsPayload = { Type = "GetPlayerPoints" }
	game.SendGameCustomMessage("Getting advancment points", pointsPayload, function(returnData)
		UpdatePlayerPoints(returnData)
	end)
end

function UpdatePlayerPoints(returnData)
	if not returnData.Success then
		print(returnData.Message)
		UI.Alert(returnData.Message)
		return
	end

	for advancmentName, advancment in pairs(Mod.Settings.Advancements) do
		if advancment.Enabled then
			UpgradePoints[advancmentName] = returnData.Points[advancmentName] or 0
		end
	end
end
