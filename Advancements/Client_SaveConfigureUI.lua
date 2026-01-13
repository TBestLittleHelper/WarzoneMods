---@type Advancements
local Advancements = {
	-- Economy ID start at 1, Culture at 30, Armies at 60 to avoid ID conflicts
	Economy = {
		Color = "#FFF700",
		Enabled = true,
		PointsPerIncome = 1,
		Upgrades = {
			{ UID = 1, Name = "Trade Stocks",     Description = "Earn 1 extra point for every 5 income you have.",  IncomeThreshold = 5,  PointsPerIncome = 1, Cost = 5,  AdvanceTurn = "End" },
			{ UID = 2, Name = "Industrial Farms", Description = "Earn 1 extra point for every 10 income you have.", IncomeThreshold = 10, PointsPerIncome = 1, Cost = 10, AdvanceTurn = "End" },
		},
	},
	Culture = {
		Color = "#880085",
		Enabled = true,
		PointsPerCity = 2,
		Upgrades = {
			{ UID = 30, Name = "National Song Competition", Description = "Earn 1 extra point for every 3 cities you own.", CitiesThreshold = 3, PointsPerCity = 1, Cost = 8, AdvanceTurn = "End" },
		},
	},
	Armies = {
		Color = "#990024",
		Enabled = true,
		PointsPerArmy = 1,
		Upgrades = {
			{ UID = 60, Name = "Mercenaries", Description = "Every 5 deployed armies comes with 1 extra army.",                     ArmiesThreshold = 5, DeployBonus = 1, Cost = 12,            AdvanceTurn = "Order" },
			{ UID = 61, Name = "Spy Network", Description = "Get a report of one random players status at the start of your turn.", SpyReports = 1,      Cost = 15,       AdvanceTurn = "Start" },
		},
	},
}

function Client_SaveConfigureUI()
	---@type Mod Mod
	Mod = Mod
	Mod.Settings.Version = 1
	Mod.Settings.Advancements = Advancements
end
