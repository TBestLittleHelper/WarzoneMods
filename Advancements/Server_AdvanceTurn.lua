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
		if upgradeUID == UpgradeUID.SpyNetwork then
			local fogLevel = WL.StandingFogLevel.OwnerOnly
			local fogPriority = 500 -- Less then other WZ effects, like cards
			local fogTerritories = {} -- todo consider picking one player?
			for territoryID, _ in pairs(game.Map.Territories) do
				table.insert(fogTerritories, territoryID)
			end
			-- https://www.warzone.com/wiki/Mod_API_Reference:FogMod
			for _, playerID in pairs(playerIDs) do
				local playersAffectedOpt = {}
				table.insert(playersAffectedOpt, playerID)
				local fogMod = WL.FogMod.Create("Spy Network", fogLevel, fogPriority, fogTerritories, playersAffectedOpt)

				local message = "Spy Network shows you who controls the world"
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

	local CultureSongUID = UpgradeUID.NationalSong

	-- todo dry, extract dupe code
	-- Income Threshold Advancements
	if ActiveAdvancementsEnd[EconomyStocksUID] then
		local incomeThreshold = Mod.Settings.Advancements.Economy.Upgrades[EconomyStocksUID].IncomeThreshold
		local pointsPerIncome = Mod.Settings.Advancements.Economy.Upgrades[EconomyStocksUID].PointsPerIncome
		for _, playerID in pairs(ActiveAdvancementsEnd[EconomyStocksUID]) do
			--https://www.warzone.com/wiki/Mod_API_Reference:GamePlayer
			local player = players[playerID]
			--todo use player and test
			local income = game.ServerGame.Game.Players[playerID].Income(0, game.ServerGame.LatestTurnStanding, false,
				false).Total
			local bonusPoints = math.floor(income / incomeThreshold) * pointsPerIncome
			PrivateGameData[playerID].Economy.Points = PrivateGameData[playerID].Economy.Points + bonusPoints
		end
	end
	if ActiveAdvancementsEnd[EconomyFarmsUID] then
		local incomeThreshold = Mod.Settings.Advancements.Economy.Upgrades[EconomyFarmsUID].IncomeThreshold
		local pointsPerIncome = Mod.Settings.Advancements.Economy.Upgrades[EconomyFarmsUID].PointsPerIncome
		for _, playerID in pairs(ActiveAdvancementsEnd[EconomyFarmsUID]) do
			--https://www.warzone.com/wiki/Mod_API_Reference:GamePlayer
			local income = game.ServerGame.Game.Players[playerID].Income(0, game.ServerGame.LatestTurnStanding, false,
				false).Total

			local bonusPoints = math.floor(income / incomeThreshold) * pointsPerIncome
			PrivateGameData[playerID].Economy.Points = PrivateGameData[playerID].Economy.Points + bonusPoints
		end
	end

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
	local Counters = { Cities = { [WL.PlayerID.Neutral] = 0 }, Armies = { [WL.PlayerID.Neutral] = 0 }, Territories = { [WL.PlayerID.Neutral] = 0 } }

	for playerID, _ in pairs(players) do
		Counters.Cities[playerID] = 0
		Counters.Armies[playerID] = 0
		Counters.Territories[playerID] = 0
	end

	for _, territory in pairs(LatestTurnStanding.Territories) do
		local ownerID = territory.OwnerPlayerID
		local structures = territory.Structures or nil

		Counters.Territories[ownerID] = Counters.Territories[ownerID] + 1
		Counters.Armies[ownerID] = Counters.Armies[ownerID] + territory.NumArmies.NumArmies;

		local cities = (structures and structures[WL.StructureType.City]) or 0
		Counters.Cities[ownerID] = Counters.Cities[ownerID] + cities
	end

	return Counters
end
