function Server_StartGame(game, standing)

    -- Setup publicGameData
    local publicGameData = Mod.PublicGameData
    publicGameData.GameFinalized = false
    publicGameData.Chat = {BroadcastGroup = BroadcastGroupSetup(game)}
    Mod.PublicGameData = publicGameData

    -- Setup playerGameData
    local playerGameData = Mod.PlayerGameData

    for _, pid in pairs(game.ServerGame.Game.Players) do
        if (pid.IsAI == false) then playerGameData[pid.ID] = {Chat = {}} end
    end
    Mod.PlayerGameData = playerGameData
end

function BroadcastGroupSetup(game)
    local BroadcastGroup = {}
    BroadcastGroup[1] = "When a game ends, all chat messages will be deleted."
    BroadcastGroup[2] =
        "Note that messages to the server is rate-limited to 5 calls every 5 seconds. Therefore, do not spam chat or group changes: it won't work!"
    BroadcastGroup[3] = "Please report any bugs and feedback to TBest."

    BroadcastGroup.NumChat = 3

    return BroadcastGroup;
end

