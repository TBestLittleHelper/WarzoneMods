require("Enums")

---@type WL WL
WL = WL

function Server_AdvanceTurn_Start(game, addNewOrder)
	-- We need to know what advancements happen when
	-- All points are saved during the end turn hook.

	-- Globals work in all advanceturn hooks
	PrivateGameData = Mod.PrivateGameData

	-- For all advancements, check if any players have them unlocked
	ActiveAdvancementsStart = {}
	ActiveAdvancementsOrder = {}
	ActiveAdvancementsEnd = {}

	for _, advancement in pairs(Mod.Settings.Advancements) do
		if advancement.Enabled then
			local Upgrades = advancement.Upgrades
			for _, upgrade in pairs(Upgrades) do
				local unlockedBy = GetUnlockedByAdvancementID(upgrade.UID, PrivateGameData)
				if #unlockedBy > 0 then
					if upgrade.AdvanceTurn == AdvanceTurn.Start then
						ActiveAdvancementsStart[upgrade.UID] = unlockedBy
					elseif upgrade.AdvanceTurn == AdvanceTurn.Order then
						ActiveAdvancementsOrder[upgrade.UID] = unlockedBy
					elseif upgrade.AdvanceTurn == AdvanceTurn.End then
						ActiveAdvancementsEnd[upgrade.UID] = unlockedBy
					end
				end
			end
		end
	end

	-- Start of turn advancements run right away
	for upgradeUID, playerIDs in pairs(ActiveAdvancementsStart) do
		if upgradeUID == UpgradeUID.SpyReportsCities then
			---@diagnostic disable-next-line: undefined-field
			local fogLevel = WL.StandingFogLevel.OwnerOnly
			local fogPriority = 500 -- Less then other WZ effects, like cards
			local fogTerritories = {}
			for territoryID, _ in pairs(game.Map.Territories) do
				table.insert(fogTerritories, territoryID)
			end
			-- https://www.warzone.com/wiki/Mod_API_Reference:FogMod
			for _, playerID in pairs(playerIDs) do
				local playersAffectedOpt = {}
				table.insert(playersAffectedOpt, playerID)
				local fogMod = WL.FogMod.Create("Spy Reports from Cities", fogLevel, fogPriority, fogTerritories,
					playersAffectedOpt)

				local message = "Spy Reports from Cities shows you who controls the world"
				-- Create a spy report order
				local spyReportEventOrder = WL.GameOrderEvent.Create(playerID, message, {})
				spyReportEventOrder.FogModsOpt = { fogMod }
				addNewOrder(spyReportEventOrder)
			end
		end
	end
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	if (order.proxyType == "GameOrderDeploy") then
		local ActiveMercenaries = ActiveAdvancementsOrder[UpgradeUID.Mercenaries]

		---@cast order GameOrderDeploy
		---@cast orderResult GameOrderDeployResult
		if ActiveMercenaries then
			if ActiveMercenaries[order.PlayerID] then
				local deployBonus = Mod.Settings.Advancements.Armies.Upgrades[UpgradeUID.Mercenaries].DeployBonus or 0
				local armiesThreshold = Mod.Settings.Advancements.Armies.Upgrades[UpgradeUID.Mercenaries]
					.ArmiesThreshold or 0

				if deployBonus == 0 or armiesThreshold == 0 then return end

				local thresholdCount = math.floor(order.NumArmies / armiesThreshold)
				local sumBonus = thresholdCount * deployBonus

				---@type TerritoryModification
				local terrMod = WL.TerritoryModification.Create(order.DeployOn)
				terrMod.AddArmies = sumBonus
				local orders = { terrMod }

				local msg = sumBonus .. " Mercenaries joined " ..
					game.Map.Territories[order.DeployOn].Name

				addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, msg, {},
					orders))
			end
		end
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	local players = game.ServerGame.Game.Players

	-- For each advancment that triggers at end turn, give points to players who have it unlocked
	local Counters = StandingCounter(game.ServerGame.LatestTurnStanding, players)


	local EconomyStocksUID = UpgradeUID.TradeStocks
	local EconomyFarmsUID = UpgradeUID.IndustrialFarms

	local CultureSongUID = UpgradeUID.NationalSongCompetition
	local CultureUrbanLifeUID = UpgradeUID.UrbanLife
	local CulturePublicEducation = UpgradeUID.PublicEducation
	local CultureSportWashing = UpgradeUID.Sportswashing

	-- Income Threshold Advancements
	-- Helper function to process economy advancements
	local function ProcessEconomyAdvancement(upgradeUID)
		if ActiveAdvancementsEnd[upgradeUID] then
			local upgrade = Mod.Settings.Advancements.Economy.Upgrades[upgradeUID]
			local incomeThreshold = upgrade.IncomeThreshold
			local pointsPerIncome = upgrade.PointsPerIncome
			for _, playerID in pairs(ActiveAdvancementsEnd[upgradeUID]) do
				local player = players[playerID]
				local income = player.Income(0, game.ServerGame.LatestTurnStanding, false, false).Total
				local bonusPoints = math.floor(income / incomeThreshold) * pointsPerIncome
				PrivateGameData[playerID].Economy.Points = PrivateGameData[playerID].Economy.Points + bonusPoints
			end
		end
	end

	ProcessEconomyAdvancement(EconomyStocksUID)
	ProcessEconomyAdvancement(EconomyFarmsUID)

	-- Culture
	if ActiveAdvancementsEnd[CultureSongUID] then
		local citiesThreshold = Mod.Settings.Advancements.Culture.Upgrades[CultureSongUID].CitiesThreshold
		local pointsPerCity = Mod.Settings.Advancements.Culture.Upgrades[CultureSongUID].PointsPerCity


		for _, playerID in pairs(ActiveAdvancementsEnd[CultureSongUID]) do
			--https://www.warzone.com/wiki/Mod_API_Reference:GamePlayer
			local numCities = Counters.Cities[playerID] or 0
			local bonusPoints = math.floor(numCities / citiesThreshold) * pointsPerCity

			print("Player " ..
				playerID .. " has " .. numCities .. " cities, earning " .. bonusPoints .. " culture points.")
			PrivateGameData[playerID].Culture.Points = PrivateGameData[playerID].Culture.Points + bonusPoints
		end

		local function ProcessDynamicIncome(upgradeUID, countTable, dataKey, messageTitle, multiplierKeyName)
			if ActiveAdvancementsEnd[upgradeUID] then
				local multiplier = Mod.Settings.Advancements.Culture.Upgrades[upgradeUID][multiplierKeyName]
				for _, playerID in pairs(ActiveAdvancementsEnd[upgradeUID]) do
					local count = countTable[playerID] or 0
					local bonusIncome = count * multiplier

					local currentBonus = PrivateGameData[playerID].Culture[dataKey] or 0
					local delta = bonusIncome - currentBonus

					if delta ~= 0 then
						local incomeMod = WL.IncomeMod.Create(playerID, delta, messageTitle)
						local event = WL.GameOrderEvent.Create(playerID, messageTitle, {})
						event.IncomeModsOpt = { incomeMod }
						addNewOrder(event)

						PrivateGameData[playerID].Culture[dataKey] = bonusIncome
					end
				end
			end
		end

		ProcessDynamicIncome(CultureUrbanLifeUID, Counters.Cities, "UrbanLifeBonus", "Urban Life Income", "IncomePerCity")
		ProcessDynamicIncome(CulturePublicEducation, Counters.Cities, "PublicEducationBonus", "Public Education Income", "IncomePerCity")
		ProcessDynamicIncome(CultureSportWashing, Counters.SpecialUnits, "SportswashingBonus", "Sportswashing Income", "IncomePerUnit")



	end

	-- Passive points so you never get stuck at zero
	local passivePoints = 100 -- todo Set to 1 after dev
	for advancementName, advancement in pairs(Mod.Settings.Advancements) do
		if advancement.Enabled then
			for _, player in pairs(game.ServerGame.Game.PlayingPlayers) do
				PrivateGameData[player.ID][advancementName].Points = PrivateGameData[player.ID][advancementName].Points +
					passivePoints

				print("Player " .. player.ID .. " has " .. PrivateGameData[player.ID][advancementName].Points ..
					" total " .. advancementName .. " points.")
			end
		end
	end


	-- Write back to server Mod object
	---@diagnostic disable-next-line: inject-field
	Mod.PrivateGameData = PrivateGameData
end

function GetUnlockedByAdvancementID(advancementID, privateGameData)
	local unlockedBy = {}
	for advancementName, advancement in pairs(Mod.Settings.Advancements) do
		if advancement.Enabled then
			for _, upgrade in pairs(advancement.Upgrades) do
				if upgrade.UID == advancementID then
					for playerID, _ in pairs(privateGameData[advancementName][upgrade.UID].UnlockedBy) do
						table.insert(unlockedBy, playerID)
					end
				end
			end
		end
	end
	return unlockedBy
end

function StandingCounter(LatestTurnStanding, players)
	---@diagnostic disable-next-line: undefined-field -- For WL.PlayerID
	local Counters = { Cities = { [WL.PlayerID.Neutral] = 0 }, Armies = { [WL.PlayerID.Neutral] = 0 }, Territories = { [WL.PlayerID.Neutral] = 0 }, SpecialUnits = { [WL.PlayerID.Neutral] = 0 } }

	for playerID, _ in pairs(players) do
		Counters.Cities[playerID] = 0
		Counters.Armies[playerID] = 0
		Counters.Territories[playerID] = 0
		Counters.SpecialUnits[playerID] = 0
	end

	for _, territory in pairs(LatestTurnStanding.Territories) do
		local ownerID = territory.OwnerPlayerID
		local structures = territory.Structures or nil

		Counters.Territories[ownerID] = Counters.Territories[ownerID] + 1
		Counters.Armies[ownerID] = Counters.Armies[ownerID] + territory.NumArmies.NumArmies;

		---@diagnostic disable-next-line: undefined-field
		local cities = (structures and structures[WL.StructureType.City]) or 0
		Counters.Cities[ownerID] = Counters.Cities[ownerID] + cities

		local units = territory.NumArmies.SpecialUnits or nil
		units = #units or 0
		Counters.SpecialUnits[ownerID] = Counters.SpecialUnits[ownerID]
			+ units
	end

	return Counters
end
