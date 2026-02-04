require("Enums")

local uid = UpgradeUID

---@type Advancements
local Advancements = {

	-- Economy ID start at 1, Culture at 30, Armies at 60 to avoid ID conflicts
	Economy = {
		Color = "#FFF700",
		Enabled = true,
		PointsPerIncome = 1,
		Upgrades = {
			[uid.TradeStocks] = {
				UID = uid.TradeStocks,
				Name = "Trade Stocks",
				Description = "Earn 1 extra economic point for every 5 income you have.",
				IncomeThreshold = 5,
				PointsPerIncome = 1,
				Cost = 5,
				AdvanceTurn = AdvanceTurn.End
			},
			[uid.IndustrialFarms] = {
				UID = uid.IndustrialFarms,
				Name = "Industrial Farms",
				Description = "Earn 1 extra economic point for every 10 income you have.",
				IncomeThreshold = 10,
				PointsPerIncome = 1,
				Cost = 10,
				AdvanceTurn = AdvanceTurn.End
			},
			[uid.UniversalBasicIncome] = {
				UID = uid.UniversalBasicIncome,
				Name = "Universal Basic Income",
				Description = "Increase your basic Income by 5",
				BasicIncome = 5,
				Cost = 25,
				AdvanceTurn = AdvanceTurn.End
			},
			[uid.WelfareFund] = {
				UID = uid.WelfareFund,
				Name = "Welfare fund",
				Description = "Increase your basic Income by 10",
				BasicIncome = 10,
				Cost = 50,
				AdvanceTurn = AdvanceTurn.End
			},
		},
	},

	Culture = {
		Color = "#880085",
		Enabled = true,
		PointsPerCity = 2,
		Upgrades = {
			[uid.NationalSongCompetition] = {
				UID = uid.NationalSongCompetition,
				Name = "National Song Competition",
				Description = "Earn 1 extra culture point for every 3 cities you own.",
				CitiesThreshold = 3,
				PointsPerCity = 1,
				Cost = 8,
				AdvanceTurn = AdvanceTurn.End
			},
			[uid.UrbanLife] = {
				UID = uid.UrbanLife,
				Name = "Urban Life",
				Description = "Increases your income by 1 for each city",
				CitiesThreshold = 1,
				IncomePerCity = 1,
				Cost = 20,
				AdvanceTurn = AdvanceTurn.End
			},
			[uid.PublicEducation] = {
				UID = uid.PublicEducation,
				Name = "Public Education",
				Description = "Increases your income by 1 for each city",
				CitiesThreshold = 1,
				IncomePerCity = 1,
				Cost = 40,
				AdvanceTurn = AdvanceTurn.End
			},
			[uid.Sportswashing] = {
				UID = uid.Sportswashing,
				Name = "Sportswashing",
				Description = "Earn 1 extra income for every special unit",
				IncomePerUnit = 1,
				PointsPerUnit = 1,
				Cost = 50,
				AdvanceTurn = AdvanceTurn.End
			},
		},
	},

	Armies = {
		Color = "#990024",
		Enabled = true,
		PointsPerArmy = 1,
		Upgrades = {
			[uid.Mercenaries] = {
				UID = uid.Mercenaries,
				Name = "Mercenaries",
				Description = "Every 5 deployed armies comes with 1 extra army.",
				ArmiesThreshold = 5,
				DeployBonus = 1,
				Cost = 12,
				AdvanceTurn = AdvanceTurn.Order
			},
			[uid.SpyReportsCities] = {
				UID = uid.SpyReportsCities,
				Name = "Spy Network in Cities",
				Description = "Remove fog of war from all cities at the start of your turn.",
				SpyReports = 1,
				Cost = 15,
				AdvanceTurn = AdvanceTurn.Start
			},
			[uid.CombatExperience] = {
				UID = uid.CombatExperience,
				Name = "Combat Experience",
				Description = "Earn 1 extra armies point for each successful attack",
				PointsPerWinningAttack = 1,
				Cost = 30,
				AdvanceTurn = AdvanceTurn.Order
			},
			[uid.InfiltrateBigArmies] = {
				UID = uid.InfiltrateBigArmies,
				Name = "Infiltrate Big Armies",
				Description = "Any big army stack will be visible on the map.",
				BigArmySize = 20,
				Cost = 35,
				AdvanceTurn = AdvanceTurn.Start
			},
			[uid.SpyReportEmpty] = {
				UID = uid.SpyReportEmpty,
				Name = "Spy empty land",
				Description = "Remove fog of war from all empty (0 armies and 0 special units) territories",
				SpyEmpty = true,
				Cost = 50,
				AdvanceTurn = AdvanceTurn.Start
			},
		},
	},
}

function Client_SaveConfigureUI()
	---@type Mod Mod
	Mod = Mod

	local CustomAdvancement = Advancements

	-- Defined in Present_Configure
	local EconomyEnabled = EconomyEnabledBox.GetIsChecked()
	local CultureEnabled = CultureEnabledBox.GetIsChecked()
	local ArmiesEnabled = ArmiesEnabledBox.GetIsChecked()

	CustomAdvancement.Economy.Enabled = EconomyEnabled
	CustomAdvancement.Culture.Enabled = CultureEnabled
	CustomAdvancement.Armies.Enabled = ArmiesEnabled

	Mod.Settings.Version = 1
	Mod.Settings.Advancements = CustomAdvancement
end
