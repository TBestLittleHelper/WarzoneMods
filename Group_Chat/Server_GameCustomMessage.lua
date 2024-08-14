require("Utilities")
require("Server_ChatData")

function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
    -- If the game is over, return
    if (Mod.PublicGameData.GameFinalized == true) then return end
    --  print("Server_GameCustomMessage")
    --    Dump(payload)

    -- Sorted according to what is probably used most
    if (payload.Message == "ReadChat") then
        ReadChat(payload, playerID)
    elseif (payload.Message == "GetGroup") then
        GetGroupPrivateGameData(playerID, payload, setReturnTable)
    elseif (payload.Message == "SendChat") then
        DeliverChat(game, playerID, payload, setReturnTable)
    elseif (payload.Message == "AddGroupMember") then
        AddToGroup(game, playerID, payload, setReturnTable)
    elseif (payload.Message == "RemoveGroupMember") then
        RemoveFromGroup(game, playerID, payload, setReturnTable)
    elseif (payload.Message == "LeaveGroup") then
        LeaveGroup(game, playerID, payload, setReturnTable)
    elseif (payload.Message == "DeleteGroup") then
        DeleteGroup(game, playerID, payload, setReturnTable)
    elseif (payload.Message == "SaveSettings") then
        SaveSettingsServer(game, playerID, payload, setReturnTable)
    elseif (payload.Message == "ClearData") then
        ClearData(game, playerID)
    else
        print("unknown Server_GameCustomMessage. : " .. payload.Message)
        setReturnTable({
            Status = "unknown Server_GameCustomMessage : " .. payload.Message
        })
    end
end

function GetGroupPrivateGameData(playerID, payload, setReturnTable)
    if payload.GroupID == nil then
        setReturnTable({Status = "Error : GroupID is missing"})
        return
    end
    -- Make sure we are a member of the group
    local group = Mod.PrivateGameData.ChatGroups[payload.GroupID]
    if (group == nil) then
        setReturnTable({Status = "Error : Group not found"})
        return
    end

    if group.Members[playerID] == nil then
        setReturnTable({Status = "Error : You are not a member of the Group"})
        return
    end

    setReturnTable({Group = group})
end

function RemoveFromGroup(game, playerID, payload, setReturnTable)
    local group = Mod.PrivateGameData.ChatGroups[payload.TargetGroupID]

    if group == nil then
        setReturnTable({Status = "Group does not exsist"})
        return
    end
    if group.OwnerID == payload.TargetPlayerID then
        setReturnTable({
            Status = "Can not remove owner from the group. Delete group instead"
        })
        return
    end
    if playerID ~= group.OwnerID then
        setReturnTable({Status = "Only the group owner can remove players"})
        return
    end

    RemoveIDFromGroup(payload.TargetGroupID, payload.TargetPlayerID, game)
    AddMessage(payload.TargetGroupID, playerID,
               game.Game.Players[payload.TargetPlayerID].DisplayName(nil, false) ..
                   " was removed from the group", game)
end

function LeaveGroup(game, playerID, payload, setReturnTable)
    local playerGameData = Mod.PlayerGameData
    local TargetGroupID = payload.TargetGroupID
    local TargetPlayerID = playerID

    if (playerGameData[playerID].Chat == nil or
        playerGameData[playerID].Chat[TargetGroupID] == nil) then
        print("No group with this ID found : " .. TargetGroupID)
        return -- Group can't be found. Do nothing
    end
    -- Check if the TargetPlayerID is the owner
    if (TargetPlayerID == playerGameData[playerID].Chat[TargetGroupID].Owner) then
        print("The owner of a group can't leave. They must use delete group")
        return
    end

    print(playerID .. " left  :" .. TargetGroupID .. " groupID")
    -- Remove the player
    local Group = playerGameData[playerID].Chat[TargetGroupID]
    removeFromSet(Group.Members, TargetPlayerID)
    -- Update the players data
    for Members, v in pairs(Group.Members) do
        playerGameData[Members].Chat[TargetGroupID] = Group
    end
    Mod.PlayerGameData = playerGameData
    -- Add a msg to the chat
    payload.Chat = game.Game.Players[TargetPlayerID].DisplayName(nil, false) ..
                       " left " .. Group.GroupName
    DeliverChat(game, playerID, payload, setReturnTable)
end

function AddToGroup(game, playerID, payload, setReturnTable)
    local targetGroupID = payload.TargetGroupID
    local TargetPlayerID = payload.TargetPlayerID
    local TargetGroupName = payload.TargetGroupName

    print(TargetPlayerID .. " targetplayer")
    print(targetGroupID .. " TargetGroupID")

    -- If group does not exsist, create group
    if Mod.PrivateGameData.ChatGroups[targetGroupID] == nil then
        CreateGroup(targetGroupID, TargetGroupName, playerID, RandomColor())
        -- Add the owner as a member of the group
        AddPlayerIDToGroup(targetGroupID, playerID, game)

    else
        -- Only owner can add members to group
        if (Mod.PrivateGameData.ChatGroups[targetGroupID].OwnerID ~= playerID) then
            setReturnTable({Status = "You are not the owner of the group!"})
            return
        end
    end

    AddPlayerIDToGroup(targetGroupID, TargetPlayerID, game)
    AddMessage(targetGroupID, playerID,
               game.Game.Players[TargetPlayerID].DisplayName(nil, false) ..
                   " is now a member of the group", game)
    -- todo Make group unread chat?
end

function DeliverChat(game, playerID, payload, setReturnTable)
    -- Make sure we are a member of the group
    if Mod.PrivateGameData.ChatGroups[payload.TargetGroupID] == nil then
        setReturnTable({Status = "Group does not exsist"})
        return
    end
    if Mod.PrivateGameData.ChatGroups[payload.TargetGroupID].Members[playerID] ==
        false then
        setReturnTable({Status = "You are not a member of the group"})
        return
    end
    -- Add Message
    AddMessage(payload.TargetGroupID, playerID, payload.Chat, game)
    -- todo Make group unread chat?
end

function ReadChat(payload, playerID, setReturnTable)
    -- Make sure we are a member of the group
    if Mod.PrivateGameData.ChatGroups[payload.TargetGroupID] == nil then
        setReturnTable({Status = "Group does not exsist"})
        return
    end
    if Mod.PrivateGameData.ChatGroups[payload.TargetGroupID].Members[playerID] ==
        false then
        setReturnTable({Status = "You are not a member of the group"})
        return
    end
    MarkRead(payload.TargetGroupID, playerID)
end

function DeleteGroup(game, playerID, payload, setReturnTable)
    -- todo
    local playerGameData = Mod.PlayerGameData
    local data = playerGameData[playerID].Chat

    local TargetGroupID = payload.TargetGroupID
    local Group = data[TargetGroupID]

    -- Make sure only the creator/owner of a group can delete it
    if (playerID ~= data[TargetGroupID].Owner) then
        print("You can't delete since you are not the owner of the group")
        return
    end
    -- Set groupID data to nil for each player
    for Members, v in pairs(Group.Members) do
        -- Make sure we skip AI's. This code is useful for testing in SP and as a safety as AI's can't have playerGameData.Chat
        if not (game.Game.Players[Members].IsAI) then
            playerGameData[Members].Chat[TargetGroupID] = nil
        end
    end
    Mod.PlayerGameData = playerGameData
    print("Deleted Group " .. TargetGroupID)
end

function SaveSettingsServer(game, playerID, payload, setReturnTable)

    -- Validate settings
    local AlertUnreadChat = (payload.AlertUnreadChat ~= nil) and
                                payload.AlertUnreadChat or true
    local NumPastChat = payload.NumPastChat or 7
    local MenuSizeX = payload.MenuSizeX or 550
    local MenuSizeY = payload.MenuSizeY or 550

    -- Save settings
    local playerGameData = Mod.PlayerGameData

    if (playerGameData == nil) then playerGameData = {} end
    if (playerGameData[playerID] == nil) then playerGameData[playerID] = {} end

    playerGameData[playerID].Settings = {
        AlertUnreadChat = AlertUnreadChat,
        NumPastChat = NumPastChat,
        MenuSizeX = MenuSizeX,
        MenuSizeY = MenuSizeY,
        TickCount = WL.TickCount()
    }
    Mod.PlayerGameData = playerGameData

    setReturnTable({Settings = Mod.PlayerGameData[playerID].Settings})
end

-- Remove data that we don't need anymore, when a game is over
function ClearData(game, playerID)
    -- 3 == playing : 4 == elim + over
    print("Server_gamecustmsg : Game.state code:")
    print(game.Game.State)
    if (game.Game.State ~= 4) then return end
    local publicGameData = Mod.PublicGameData
    -- Check that we have not allready done this
    if (publicGameData.ChatModEnabled == false) then return end
    -- TODO move playerGameData to publicgamedata
    -- Remove all playerGameData
    local playerGameData = Mod.PlayerGameData
    for Players in pairs(playerGameData) do
        print("Deleted playerGameData.Chat for " .. Players)
        playerGameData[Players].Chat = {}
    end

    Mod.PlayerGameData = playerGameData

    -- Remove all publicGameData and set a bool flag to false
    publicGameData.ChatModEnabled = false
    Mod.PublicGameData = publicGameData
end

