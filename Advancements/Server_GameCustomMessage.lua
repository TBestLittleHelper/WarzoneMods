function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
	local returnData = {
		Success = false,
		Message = "Invalid request."
	}
	setReturnTable(returnData)

	if payload == nil or payload.Type == nil then
		return
	end

	local privateGameData = Mod.PrivateGameData

	if payload.Type == "GetUnlocked" then
		local unlocked = GetUnlockedByPlayerID(playerID, privateGameData)
		returnData = {
			Success = true,
			Message = "Unlocked upgrades retrieved successfully.",
			UnlockedUpgrades = unlocked
		}
		setReturnTable(returnData)
		return
	end

	if payload.Type == "UnlockUpgrade" then
		local advancmentName = payload.AdvancementName or ""
		if advancmentName == "" then
			returnData.Message = "Invalid advancement name."
			setReturnTable(returnData)
			return
		end
		local upgradeUID = payload.UpgradeUID or -1
		if upgradeUID == -1 then
			returnData.Message = "Invalid upgrade UID."
			setReturnTable(returnData)
			return
		end

		local upgrade = Mod.Settings.Advancements[advancmentName].Upgrades[payload.UpgradeUID]
		if upgrade == nil then
			returnData.Message = "No upgrade found with UID " .. payload.UpgradeUID .. "."
			setReturnTable(returnData)
			return
		end

		local playerPoints = privateGameData[playerID][advancmentName].Points
		local cost = Mod.Settings.Advancements[advancmentName].Upgrades[upgradeUID].Cost

		if playerPoints < cost then
			returnData.Message = "Not enough points to unlock upgrade."
			setReturnTable(returnData)
			return
		end

		-- Remove points and unlock upgrade
		privateGameData[playerID][advancmentName].Points = playerPoints - cost
		privateGameData[advancmentName][upgradeUID].UnlockedBy[playerID] = true

		---@diagnostic disable-next-line: inject-field
		Mod.PrivateGameData = privateGameData

		returnData.Success = true
		returnData.Message = "Upgrade unlocked successfully."
		setReturnTable(returnData)
	end

	if payload.Type == "GetPlayerPoints" then
		returnData.Message = "Failed to get player points."
		setReturnTable(returnData)

		local Points = {};
		for advancementName, advancement in pairs(Mod.Settings.Advancements) do
			if advancement.Enabled then
				Points[advancementName] = privateGameData[playerID][advancementName].Points or 0
			end
		end

		returnData.Success = true
		returnData.Message = "Player points retrieved successfully."
		returnData.Points = Points
		setReturnTable(returnData)

		return
	end
end

function GetUnlockedByPlayerID(playerID, privateGameData)
	local unlockables = {}
	for advancementName, advancement in pairs(Mod.Settings.Advancements) do
		if advancement.Enabled then
			for _, upgrade in pairs(advancement.Upgrades) do
				if privateGameData[advancementName][upgrade.UID].UnlockedBy[playerID] then
					table.insert(unlockables, upgrade.UID)
				end
			end
		end
	end
	return unlockables
end
