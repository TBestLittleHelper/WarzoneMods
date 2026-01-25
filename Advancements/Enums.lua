-- Any changes here must also be reflected in Types.lua

AdvancementType = {
	Economy = "Economy",
	Culture = "Culture",
	Armies  = "Armies",
}

AdvanceTurn = {
	Start = "Start",
	Order = "Order",
	End   = "End",
}

UpgradeUID = {
	-- Economy (1–29)
	TradeStocks             = 1,
	IndustrialFarms         = 2,
	UniversalBasicIncome    = 3,
	WelfareFund             = 4,

	-- Culture (30–59)
	NationalSongCompetition = 30,
	UrbanLife               = 31,
	PublicEducation         = 32,
	Sportswashing           = 33,

	-- Armies (60+)
	Mercenaries             = 60,
	SpyReportsCities        = 61,
	CombatExperience        = 62,
	InfiltrateBigArmies     = 63,
}
