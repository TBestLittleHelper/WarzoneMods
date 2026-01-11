function Server_StartGame(game, standing)
	-- Writable copy of Mod.PrivateGameData
	local privateGameData = Mod.PrivateGameData
	privateGameData.Advancement = {}

	-- Data structure:
	--	privateGameData = {
	--		[playerID] = {
	--			Economy = { Points = 0 },
	--			Culture = { Points = 0 },
	--			Armies  = { Points = 0 }
	--		},
	--		[advancmentName] = {
	--			[upgradeUID] = { UnlockedBy = {} }
	--		}
	--	}


	for _, player in pairs(game.ServerGame.Game.Players) do
		privateGameData[player.ID] = privateGameData[player.ID] or {}
	end

	for advancmentName, advancement in pairs(Mod.Settings.Advancments) do
		if advancement.Enabled then
			for _, player in pairs(game.ServerGame.Game.Players) do
				privateGameData[player.ID][advancmentName] = { Points = 0 }
			end

			privateGameData[advancmentName] = {}
			local Upgrades = advancement.Upgrades
			for _, upgrade in pairs(Upgrades) do
				privateGameData[advancmentName][upgrade.UID] = {
					UnlockedBy = {}
				}
			end
		end
	end

	-- Write back to server Mod object
	---@diagnostic disable-next-line: inject-field
	Mod.PrivateGameData = privateGameData
end
