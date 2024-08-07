require("ChatData")
function GameDataSetup(game)
    -- Make sure Setup can only be run once ( StartDistribution and StartGame may both run)
    if (Mod.PrivateGameData.ChatGroups ~= nil) then return end

    local publicGameData = Mod.PublicGameData
    local playerGameData = Mod.PlayerGameData
    local privateGameData = Mod.PrivateGameData

    local groupID = WL.TickCount()

    local humanPlayers = {};
    for _, player in pairs(game.ServerGame.Game.Players) do
        if (player.IsAI == false) then
            playerGameData[player.ID] = {
                ChatGroupMember = {
                    [groupID] = {Name = "test", Color = "#880085"}
                }
            }
            table.insert(humanPlayers, player.ID)
        end
    end

    privateGameData = {
        ChatGroups = {
            [groupID] = {
                Name = "System",
                OwnerID = -1,
                ChatHistory = {},
                Color = "#880085",
                Members = humanPlayers
            }
        }
    }
    AddMessage(privateGameData.ChatGroups[groupID].ChatHistory, -1,
               "When a game ends, all chat messages will be deleted.")
    AddMessage(privateGameData.ChatGroups[groupID].ChatHistory, -1,
               "Note that messages to the server is rate-limited. Therefore, do not spam chat or group changes: it won't work!")
    AddMessage(privateGameData.ChatGroups[groupID].ChatHistory, -1,
               "Please report any bugs and feedback to TBest.")

    publicGameData.GameFinalized = false

    -- Save to server
    Mod.PublicGameData = publicGameData
    Mod.PlayerGameData = playerGameData
    Mod.PrivateGameData = privateGameData
end

