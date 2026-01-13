---@type WL WL
WL = WL

function Server_AdvanceTurn_Start(game, addNewOrder)
	-- We need to know what advancments happen when
	-- All points are saved during the end turn hook.

	-- Globals work in all advanceturn hooks
	PrivateGameData = Mod.PrivateGameData

	-- For all advancments, check if any players have them unlocked
	ActiveAdvancmentsStart = {}
	ActiveAdvancmentsOrder = {}
	ActiveAdvancmentsEnd = {}

	for advancmentName, advancment in pairs(Mod.Settings.Advancments) do
		if advancment.Enabled then
			ActiveAdvancmentsStart[advancmentName] = {}
			ActiveAdvancmentsOrder[advancmentName] = {}
			ActiveAdvancmentsEnd[advancmentName] = {}

			local Upgrades = advancment.Upgrades
			for _, upgrade in pairs(Upgrades) do
				local unlockedBy = GetUnlockedByAdvancmentID(upgrade.UID, PrivateGameData)
				if unlockedBy ~= {} then
					if upgrade.AdvanceTurn == "Start" then
						ActiveAdvancmentsStart[upgrade.UID] = unlockedBy
					elseif upgrade.AdvanceTurn == "Order" then
						ActiveAdvancmentsOrder[upgrade.UID] = unlockedBy
					elseif upgrade.AdvanceTurn == "End" then
						ActiveAdvancmentsEnd[upgrade.UID] = unlockedBy
					end
				end
			end
		end
	end

	-- Start of turn advancments run right away
	for upgradeUID, playerIDs in pairs(ActiveAdvancmentsStart) do
		if upgradeUID == 61 then -- Spy Network
			for _, playerID in pairs(playerIDs) do
				-- Get a random other player
				local otherPlayers = {}
				for _, player in pairs(game.ServerGame.Game.PlayingPlayers) do
					if player.ID ~= playerID then
						table.insert(otherPlayers, player)
					end
				end
				if #otherPlayers > 0 then
					local randomIndex = math.random(1, #otherPlayers)
					local targetPlayer = otherPlayers[randomIndex]

					-- todo display name
					local message = targetPlayer .. " has Territories and Income"
					-- Create a report order
					local spyReportOrder = WL.GameOrderEvent.Create(playerID, message, {})
					addNewOrder(spyReportOrder)
				end
			end
		end
	end
end

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)

end

function Server_AdvanceTurn_End(game, addNewOrder)
	-- For each advancment that triggers at end turn, give points to players who have it unlocked
	local Counters = StandingCounter(game.ServerGame.LatestTurnStanding, game.ServerGame.Game.Players)


	local EconomyStocksUID = 1
	local EconomyFarmsUID = 2

	local CultureSongCompetitionUID = 30

	-- todo dry, extract dupe code
	-- Income Threshold Advancments
	if ActiveAdvancmentsEnd[EconomyStocksUID] then
		local incomeThreshold = Mod.Settings.Advancments.Economy.Upgrades[EconomyStocksUID].IncomeThreshold
		local pointsPerIncome = Mod.Settings.Advancments.Economy.Upgrades[EconomyStocksUID].PointsPerIncome
		for _, playerID in pairs(ActiveAdvancmentsEnd[EconomyStocksUID]) do
			--https://www.warzone.com/wiki/Mod_API_Reference:GamePlayer
			local income = game.ServerGame.Game.Players[playerID].Income(0, game.ServerGame.LatestTurnStanding, false,
				false)

			local bonusPoints = math.floor(income / incomeThreshold) * pointsPerIncome
			PrivateGameData[playerID].Economy.Points = PrivateGameData[playerID].Economy.Points + bonusPoints
		end
	end
	if ActiveAdvancmentsEnd[EconomyFarmsUID] then
		local incomeThreshold = Mod.Settings.Advancments.Economy.Upgrades[EconomyFarmsUID].IncomeThreshold
		local pointsPerIncome = Mod.Settings.Advancments.Economy.Upgrades[EconomyFarmsUID].PointsPerIncome
		for _, playerID in pairs(ActiveAdvancmentsEnd[EconomyFarmsUID]) do
			--https://www.warzone.com/wiki/Mod_API_Reference:GamePlayer
			local income = game.ServerGame.Game.Players[playerID].Income(0, game.ServerGame.LatestTurnStanding, false,
				false)

			local bonusPoints = math.floor(income / incomeThreshold) * pointsPerIncome
			PrivateGameData[playerID].Economy.Points = PrivateGameData[playerID].Economy.Points + bonusPoints
		end
	end

	-- Culture
	if ActiveAdvancmentsEnd[CultureSongCompetitionUID] then
		local citiesThreshold = Mod.Settings.Advancments.Culture.Upgrades[CultureSongCompetitionUID].CitiesThreshold
		local pointsPerCity = Mod.Settings.Advancments.Culture.Upgrades[CultureSongCompetitionUID].PointsPerCity


		for _, playerID in pairs(ActiveAdvancmentsEnd[CultureSongCompetitionUID]) do
			--https://www.warzone.com/wiki/Mod_API_Reference:GamePlayer
			local numCities = #game.ServerGame.Game.Players[playerID]:GetTerritories(WL.TerritoryType.City, nil)

			local bonusPoints = math.floor(numCities / citiesThreshold) * pointsPerCity
			PrivateGameData[playerID].Culture.Points = PrivateGameData[playerID].Culture.Points + bonusPoints
		end
	end


	-- Write back to server Mod object
	---@diagnostic disable-next-line: inject-field
	Mod.PrivateGameData = PrivateGameData
end

function GetUnlockedByAdvancmentID(advancmentID, privateGameData)
	local unlockedBy = {}
	for advancmentName, advancement in pairs(Mod.Settings.Advancments) do
		if advancement.Enabled then
			for _, upgrade in pairs(advancement.Upgrades) do
				if upgrade.UID == advancmentID then
					for playerID, _ in pairs(privateGameData[advancmentName][upgrade.UID].UnlockedBy) do
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
		local structures = territory.Structure

		Counters.Territories[ownerID] = Counters.Territories[ownerID] + 1
		Counters.Armies[ownerID] = Counters.Armies[ownerID] + territory.NumArmies.NumArmies;

		if structures ~= nil and structures ~= {} then
			if structures[WL.StructureType.City] ~= nil then
				Counters.Cities[ownerID] = Counters.Cities[ownerID] + structures[WL.StructureType.City]
			end
		end

		Counters.Territories[ownerID] = Counters.Territories[ownerID] + 1
	end

	return Counters
end
