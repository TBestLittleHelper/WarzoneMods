function GameDataSetup(game)
    local publicGameData = Mod.PublicGameData
    local privateGameData = Mod.PrivateGameData

    -- Make sure Setup can only be run once ( StartDistribution and StartGame may both run)
    if (publicGameData.Chat ~= nil) then return end

    local SystemChat = {
        "When a game ends, all chat messages will be deleted.",
        "Note that messages to the server is rate-limited to 5 calls every 5 seconds. Therefore, do not spam chat or group changes: it won't work!",
        "Please report any bugs and feedback to TBest."
    }
    local groupID = WL.TickCount()
    local humanePlayers = {};
    for _, player in pairs(game.ServerGame.Game.Players) do
        print(player.ID)
        if (player.IsAI == false) then
            table.insert(humanePlayers, player.ID)
        end
    end

    privateGameData = {
        ChatGroups = {
            GroupID,
            OwnerID = -1,
            ChatHistory = SystemChat,
            Color = "#880085",
            Members = humanePlayers
        }
    }

    publicGameData.GameFinalized = false

    -- Save to server
    Mod.PublicGameData = publicGameData;
    Mod.PrivateGameData = privateGameData;

end

