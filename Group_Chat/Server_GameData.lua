require("Server_ChatData")
function GameDataSetup(game)
    -- Make sure setup can only be run once ( StartDistribution and StartGame may both run)
    if (Mod.PrivateGameData.ChatGroups ~= nil) then return end

    local publicGameData = Mod.PublicGameData
    local privateGameData = Mod.PrivateGameData

    publicGameData.GameFinalized = false
    privateGameData.ChatGroups = {}

    -- Save to server
    Mod.PublicGameData = publicGameData
    Mod.PrivateGameData = privateGameData

    -- Logic to create a System chat group, with all human players
    local groupID = WL.TickCount()
    CreateGroup(groupID, "System", -1, "#880085")

    for _, player in pairs(game.ServerGame.Game.Players) do
        AddPlayerIDToGroup(groupID, player.ID, game)
    end

    -- Use AddSystemMessage instead, to not mark it as unread for players
    local function AddSystemMessage(groupID, senderID, chat)
        local privateGameDate = Mod.PrivateGameData
        table.insert(privateGameDate.ChatGroups[groupID].ChatHistory,
                     {SenderID = senderID, Chat = chat})
        Mod.PrivateGameData = privateGameDate

    end

    AddSystemMessage(groupID, -1,
                     "When a game ends, all chat messages will be deleted.")
    AddSystemMessage(groupID, -1,
                     "Note that messages to the server is rate-limited. Therefore, do not spam chat or group changes: it won't work!")
    AddSystemMessage(groupID, -1,
                     "Please report any bugs and feedback to TBest.")

end

