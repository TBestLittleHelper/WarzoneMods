function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	if game.Us == nil then
		UI.Alert("You can't do anything as a spectator.")
		return
	end

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
	local upgradePoints = 0

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

			local isAffordable = upgrade.Cost <= upgradePoints
			local btn = UI.CreateButton(line).SetText(upgrade.Name).SetInteractable(isAffordable)
			table.insert(upgradeUIElements, btn)
		end
	end

	-- Buttons
	UI.CreateButton(advancmentButtons).SetInteractable(false).SetText(upgradePoints .. " Points")


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

	-- todo test
	UI.CreateButton(advancmentButtons).SetText("Refresh").SetOnClick(function()
		close()
		Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	end)
end
