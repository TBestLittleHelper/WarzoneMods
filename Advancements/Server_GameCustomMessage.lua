function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
	if payload == nil or payload.Type == nil then
		return
	end

	local privateGameData = Mod.PrivateGameData

	if payload.Type == "GetUnlocked" then
		local unlocked = GetUnlockedByPlayerID(playerID, privateGameData)

		setReturnTable(unlocked)
		return
	end

	if payload.Type == "UnlockUpgrade" then
		-- Validate payload
		local returnData = {
			Success = false,
			Message = "Failed to unlock upgrade."
		}
		setReturnTable(returnData)

		local advancmentName = payload.AdvancmentName or ""
		if advancmentName == "" then
			returnData.Message = "Invalid advancment name."
			setReturnTable(returnData)
			return
		end
		local upgradeUID = payload.UpgradeUID or -1
		if upgradeUID == -1 then
			returnData.Message = "Invalid upgrade UID."
			setReturnTable(returnData)
			return
		end

		local upgrade = Mod.Settings.Advancments[advancmentName].Upgrades[payload.UID]
		if upgrade == nil then
			returnData.Message = "No upgrade found with UID " .. payload.UID .. "."
			setReturnTable(returnData)
			return
		end

		local playerPoints = privateGameData[playerID][payload.AdvancmentName].Points
		local cost = Mod.Settings.Advancments[advancmentName].Upgrades[upgradeUID].Cost

		if playerPoints < cost then
			returnData.Message = "Not enough points to unlock upgrade."
			setReturnTable(returnData)
			return
		end

		-- Remove points and unlock upgrade
		privateGameData[playerID][payload.AdvancmentName].Points = playerPoints - cost
		privateGameData[advancmentName][upgradeUID].UnlockedBy[playerID] = true

		---@diagnostic disable-next-line: inject-field
		Mod.PrivateGameData = privateGameData

		returnData.Success = true
		returnData.Message = "Upgrade unlocked successfully."
		setReturnTable(returnData)
	end
end

function GetUnlockedByPlayerID(playerID, privateGameData)
	local unlockables = {}
	for advancmentName, advancement in pairs(Mod.Settings.Advancments) do
		if advancement.Enabled then
			for _, upgrade in pairs(advancement.Upgrades) do
				if privateGameData[advancmentName][upgrade.UID].UnlockedBy[playerID] then
					table.insert(unlockables, upgrade.UID)
				end
			end
		end
	end
	return unlockables
end
