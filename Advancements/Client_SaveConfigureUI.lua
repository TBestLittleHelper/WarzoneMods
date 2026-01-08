local Advancments = {
	Economy = {
		Enabled = true,
		PointsPerIncome = 1,
		Upgrades = {
			{ Name = "Buy Stocks",  Description = "Earn 1 extra point for every 5 income you have.",  IncomeThreshold = 5,  PointsPerIncome = 1, Cost = 5 },
			{ Name = "Build Farms", Description = "Earn 1 extra point for every 10 income you have.", IncomeThreshold = 10, PointsPerIncome = 1, Cost = 10 }
		},
	}
}

function Client_SaveConfigureUI()
	---@type Mod Mod
	Mod = Mod
	Mod.Settings.Version = 1
	Mod.Settings.Advancments = Advancments
end
