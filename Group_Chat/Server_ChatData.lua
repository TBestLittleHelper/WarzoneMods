require("Utilities")

function AddMessage(groupID, senderID, chat, game)
    local privateGameDate = Mod.PrivateGameData
    table.insert(privateGameDate.ChatGroups[groupID].ChatHistory,
                 {SenderID = senderID, Chat = chat})
    Mod.PrivateGameData = privateGameDate
    -- For all group members, mark unread with last chat
    for playerID, _ in pairs(privateGameDate.ChatGroups[groupID].Members) do
        MarkUnread(groupID, senderID, playerID, chat, game)
    end
end
function MarkUnread(groupID, senderID, playerID, chat, game)
    -- AI's do not have PlayerGameData nor UI
    if (game.ServerGame.Game.Players[playerID].IsAI) then return end

    -- Add to playerGameData for UI use
    local playerGameData = Mod.PlayerGameData
    playerGameData[playerID].ChatGroupMember[groupID].UnreadChat = {
        SenderID = senderID,
        Chat = chat
    }
    Mod.PlayerGameData = playerGameData
end
function MarkRead(groupID, playerID)
    -- AI's do not have PlayerGameData.
    if (game.ServerGame.Game.Players[playerID].IsAI) then return end

    -- Add to playerGameData for UI use
    local playerGameData = Mod.PlayerGameData
    playerGameData[playerID].ChatGroupMember[groupID].UnreadChat = nil
    Mod.PlayerGameData = playerGameData
end

function DeleteGroup(groupID)
    -- Remove group from all PlayerGameData
    local playerGameData = Mod.playerGameData
    for playerID, _ in pairs(playerGameData.ChatGroups[groupID].Members) do
        if not (game.Game.Players[Members].IsAI) then
            playerGameData[playerID].ChatGroupMember[groupID] = nil
        end
    end
    Mod.PlayerGameData = playerGameData

    -- Delete from PrivateGameData
    local privateGameDate = Mod.PrivateGameData
    privateGameDate.ChatGroups[groupID] = nil
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

function RemoveIDFromGroup(groupID, playerID, game)
    -- Remove from PrivateGameData
    local privateGameDate = Mod.PrivateGameData
    privateGameDate.ChatGroups[groupID].Members[playerID] = nil
    Mod.PrivateGameData = privateGameDate

    -- AI's do not have PlayerGameData.
    if (game.ServerGame.Game.Players[playerID].IsAI) then return end

    -- Remove the group from playerID's UI
    local playerGameData = Mod.PlayerGameData
    playerGameData[playerID].ChatGroupMember[groupID] = nil
    Mod.PlayerGameData = playerGameData
end
