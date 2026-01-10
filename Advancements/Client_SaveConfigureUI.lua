local Advancments = {
	Economy = {
		Color = "#FFF700",
		Enabled = true,
		PointsPerIncome = 1,
		Upgrades = {
			{ Name = "Buy Stocks",  Description = "Earn 1 extra point for every 5 income you have.",  IncomeThreshold = 5,  PointsPerIncome = 1, Cost = 5 },
			{ Name = "Build Farms", Description = "Earn 1 extra point for every 10 income you have.", IncomeThreshold = 10, PointsPerIncome = 1, Cost = 10 }
		},
	},
	Culture = {
		Color = "#00FFAA",
		Enabled = true,
		PointsPerCity = 2,
		Upgrades = {
			{ Name = "National Song Competition", Description = "Earn 1 extra point for every 3 cities you own.", CitiesThreshold = 3, PointsPerCity = 1, Cost = 8 },
		},
	},
	Armies = {
		Color = "#FF00AA",
		Enabled = true,
		PointsPerArmy = 1,
		Upgrades = {
			{ Name = "Mercenaries", Description = "Every 5 deployed armies comes with 1 extra army.", ArmiesThreshold = 5, DeployBonus = 1, Cost = 12 },
		},
	},
}

function Client_SaveConfigureUI()
	---@type Mod Mod
	Mod = Mod
	Mod.Settings.Version = 1
	Mod.Settings.Advancments = Advancments
end
