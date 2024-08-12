require("Utilities")

function AddMessage(groupID, senderID, chat)
    local privateGameDate = Mod.PrivateGameData
    table.insert(privateGameDate.ChatGroups[groupID].ChatHistory,
                 {SenderID = senderID, Chat = chat})
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
end

function AddPlayerIDToGroup(groupID, playerID, game)
    -- Add to PrivateGameData
    local privateGameDate = Mod.PrivateGameData
    privateGameDate.ChatGroups[groupID].Members[playerID] = true
    Mod.PrivateGameData = privateGameDate

    -- AI's do not have PlayerGameData.
    if (game.ServerGame.Game.Players[playerID].IsAI) then return end

    -- Add to playerGameData for UI use
    local playerGameData = Mod.PlayerGameData
    if (playerGameData[playerID] == nil) then
        playerGameData[playerID] = {ChatGroupMember = {}}
    end
    if (playerGameData[playerID].ChatGroupMember == nil) then
        playerGameData[playerID].ChatGroupMember = {}
    end

    playerGameData[playerID].ChatGroupMember[groupID] = {
        Name = privateGameDate.ChatGroups[groupID].Name,
        Color = privateGameDate.ChatGroups[groupID].Color,
        UnreadChat = false,
        OwnerID = privateGameDate.ChatGroups[groupID].OwnerID
    }

    Mod.PlayerGameData = playerGameData

end

function RemoveIDFromGroup(groupID, playerID, game) end

function UpdateAllGroupMembers(game, playerID, groupID, playerGameData)
    local playerGameData = playerGameData
    local ReffrencePlayerData = playerGameData[playerID].Chat -- We already updated the info for this player. Now we need to sync that to the other players --TODO SP test Server_GameCustomMessage.lua:(221,1-222,0): attempt to index a nil value

    local Group = ReffrencePlayerData[groupID]
    local outdatedPlayerData

    -- Update playerGameData for each member
    for Members, v in pairs(Group.Members) do
        -- Make sure we don't add AI's. This code is useful for testing in SP and as a safety
        if (game.Game.Players[Members].IsAI == false) then
            outdatedPlayerData = playerGameData[Members].Chat
            -- if nil, make an empty table where we can place GroupID
            if (outdatedPlayerData == nil) then
                outdatedPlayerData = {}
            end
            outdatedPlayerData[groupID] = Group
            playerGameData[Members].Chat = outdatedPlayerData
        end
    end
    -- Finally write back to Mod.PlayerGameData
    Mod.PlayerGameData = playerGameData
end
