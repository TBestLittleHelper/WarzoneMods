require("Enums")

---@type Advancements
local Advancements = {
	-- Economy ID start at 1, Culture at 30, Armies at 60 to avoid ID conflicts
	Economy = {
		Color = "#FFF700",
		Enabled = true,
		PointsPerIncome = 1,
		Upgrades = {
			{ UID = 1, Name = "Trade Stocks",     Description = "Earn 1 extra point for every 5 income you have.",  IncomeThreshold = 5,  PointsPerIncome = 1, Cost = 5,  AdvanceTurn = "End" },
			{ UID = 2, Name = "Industrial Farms", Description = "Earn 1 extra point for every 10 income you have.", IncomeThreshold = 10, PointsPerIncome = 1, Cost = 10, AdvanceTurn = "End" }, { UID = 3, Name = "Universal Basic Income", Description = "Increase your basic Income by 5", BasicIncome = 5, Cost = 50, AdvanceTurn = "End" }
		},
	},
	Culture = {
		Color = "#880085",
		Enabled = true,
		PointsPerCity = 2,
		Upgrades = {
			[30] =
			{ UID = 30, Name = "National Song Competition", Description = "Earn 1 extra point for every 3 cities you own.", CitiesThreshold = 3, PointsPerCity = 1, Cost = 8, AdvanceTurn = AdvanceTurn.End },
		},
	},
	Armies = {
		Color = "#990024",
		Enabled = true,
		PointsPerArmy = 1,
		Upgrades = {
			[60] =
			{ UID = 60, Name = "Mercenaries", Description = "Every 5 deployed armies comes with 1 extra army.", ArmiesThreshold = 5, DeployBonus = 1, Cost = 12, AdvanceTurn = AdvanceTurn.Order },
			[61] = { UID = 61, Name = "Spy Network", Description = "Get a report of one random players status at the start of your turn.", SpyReports = 1, Cost = 15, AdvanceTurn = AdvanceTurn.Start },
		},
	},
}

function Client_SaveConfigureUI()
	---@type Mod Mod
	Mod = Mod

	local CustomAdvancment = Advancements

	-- Defined in Present_Configure
	local EconomyEnabled = EconomyEnabledBox.GetIsChecked()
	local CultureEnabled = CultureEnabledBox.GetIsChecked()
	local ArmiesEnabled = ArmiesEnabledBox.GetIsChecked()

	CustomAdvancment.Economy.Enabled = EconomyEnabled
	CustomAdvancment.Culture.Enabled = CultureEnabled
	CustomAdvancment.Armies.Enabled = ArmiesEnabled

	Mod.Settings.Version = 1
	Mod.Settings.Advancements = CustomAdvancment
end
