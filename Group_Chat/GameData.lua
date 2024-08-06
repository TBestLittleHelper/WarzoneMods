function GameDataSetup(game)
    local publicGameData = Mod.PublicGameData
    local playerGameData = Mod.PlayerGameData

    -- Make sure Setup can only be run once ( StartDistribution and StartGame may both run)
    if (publicGameData.Chat ~= nil) then return end
    local function broadcastGroupSetup(game)
        local BroadcastGroup = {}
        BroadcastGroup[1] =
            "When a game ends, all chat messages will be deleted."
        BroadcastGroup[2] =
            "Note that messages to the server is rate-limited to 5 calls every 5 seconds. Therefore, do not spam chat or group changes: it won't work!"
        BroadcastGroup[3] = "Please report any bugs and feedback to TBest."
        BroadcastGroup.NumChat = 3
        return BroadcastGroup;
    end

    for _, pid in pairs(game.ServerGame.Game.Players) do
        if (pid.IsAI == false) then playerGameData[pid.ID] = {Chat = {}} end
    end

    publicGameData.GameFinalized = false
    publicGameData.Chat = {BroadcastGroup = broadcastGroupSetup(game)}

    -- Save to server
    Mod.PublicGameData = publicGameData;
    Mod.PlayerGameData = playerGameData;
end
