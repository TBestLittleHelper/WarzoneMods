function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	if (game.Us == nil) then
		UI.Alert("You can't do anything as a spectator.")
		return
	end

	setMaxSize(550, 650)
	setScrollable(false, true)

	Advancements = Mod.Settings.Advancments

	---@type UI UI
	UI = UI
	local verticalMainLayout = UI.CreateVerticalLayoutGroup(rootParent)
	local advancmentButtons = UI.CreateHorizontalLayoutGroup(verticalMainLayout)
	local advancmentUpgradeArea = UI.CreateHorizontalLayoutGroup(verticalMainLayout)

	if Advancements.Economy.Enabled then
		UI.CreateButton(advancmentButtons).SetText("Economy").SetColor(Advancements.Economy.Color).SetOnClick(function()
			SelectAdvancment("Economy", advancmentUpgradeArea, Advancements.Economy.Upgrades)
		end)
	end
	if Advancements.Culture.Enabled then
		UI.CreateButton(advancmentButtons).SetText("Culture").SetColor(Advancements.Culture.Color).SetOnClick(function()
			SelectAdvancment("Culture", advancmentUpgradeArea, Advancements.Culture.Upgrades)
		end)
	end
	if Advancements.Armies.Enabled then
		UI.CreateButton(advancmentButtons).SetText("Armies").SetColor(Advancements.Armies.Color).SetOnClick(function()
			SelectAdvancment("Armies", advancmentUpgradeArea, Advancements.Armies.Upgrades)
		end)
	end
end

---@type fun(advancment: "Economy" | "Culture" | "Armies", advancmentUpgradeArea, upgrades)
SelectAdvancment = function(advancment, advancmentUpgradeArea, upgrades)
	print("Selected Advancment: " .. advancment)
	for _, upgrade in ipairs(upgrades) do
		local upgradeLine = UI.CreateHorizontalLayoutGroup(advancmentUpgradeArea)
		UI.CreateButton(upgradeLine).SetText(upgrade.Name)
	end
end
