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
end

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)

end

function Server_AdvanceTurn_End(game, addNewOrder)
	PrivateGameData = Mod.PrivateGameData
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
