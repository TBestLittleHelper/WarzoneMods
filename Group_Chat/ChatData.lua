require("Utilities")

function AddMessage(groupID, senderID, chat)
    local privateGameDate = Mod.PrivateGameData
    table.insert(privateGameDate.ChatGroups[groupID].ChatHistory,
                 {senderID = senderID, chat = chat})
    Mod.PrivateGameData = privateGameDate
end

function CreateGroup(groupID, Name, OwnerID, Color)
    local privateGameDate = Mod.PrivateGameData
    privateGameDate.ChatGroups[groupID] = {
        Name = Name,
        OwnerID = OwnerID,
        ChatHistory = {},
        Color = Color,
        Members = {}
    }

    Mod.PrivateGameData = privateGameDate
    print("createdGroup")
    Dump(Mod.PrivateGameData.ChatGroups[groupID])
end

function AddPlayerIDToGroup(groupID, playerID)
    -- Add to PrivateGameData
    local privateGameDate = Mod.PrivateGameData
    privateGameDate.ChatGroups[groupID].Members[playerID] = true

    -- Add to PlayerGameData
    local playerGameData = Mod.PlayerGameData

    playerGameData[playerID] = {
        ChatGroupMember = {
            [groupID] = {
                Name = privateGameDate.ChatGroups[groupID].Name,
                Color = privateGameDate.ChatGroups[groupID].Color
            }
        }
    }

    Mod.PrivateGameData = privateGameDate
    Mod.PlayerGameData = playerGameData

end
