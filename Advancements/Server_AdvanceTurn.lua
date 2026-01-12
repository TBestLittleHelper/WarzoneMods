---@type WL WL
WL=WL

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


	for

	-- Income Threshold Advancments
	if ActiveAdvancmentsEnd[1] then
		local incomeThreshold = Mod.Settings.Advancments.Economy.Upgrades[1].IncomeThreshold
		local pointsPerIncome = Mod.Settings.Advancments.Economy.Upgrades[1].PointsPerIncome
		for _, playerID in pairs(ActiveAdvancmentsEnd[1]) do
			--https://www.warzone.com/wiki/Mod_API_Reference:GamePlayer
			local income = game.ServerGame.Game.Players[playerID].Income(0, game.ServerGame.LatestTurnStanding, false,
				false)

			local bonusPoints = math.floor(income / incomeThreshold) * pointsPerIncome
			PrivateGameData[playerID].Economy.Points = PrivateGameData[playerID].Economy.Points + bonusPoints
		end
	end
	if ActiveAdvancmentsEnd[2] then
		local incomeThreshold = Mod.Settings.Advancments.Economy.Upgrades[2].IncomeThreshold
		local pointsPerIncome = Mod.Settings.Advancments.Economy.Upgrades[2].PointsPerIncome
		for _, playerID in pairs(ActiveAdvancmentsEnd[2]) do
			--https://www.warzone.com/wiki/Mod_API_Reference:GamePlayer
			local income = game.ServerGame.Game.Players[playerID].Income(0, game.ServerGame.LatestTurnStanding, false,
				false)

			local bonusPoints = math.floor(income / incomeThreshold) * pointsPerIncome
			PrivateGameData[playerID].Economy.Points = PrivateGameData[playerID].Economy.Points + bonusPoints
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
