require("Utilities")

function Server_GameCustomMessage(game, playerID, payload, setReturnTable)
    -- If the game is over, return
    if (Mod.PublicGameData.GameFinalized == true) then return end
    Dump(payload)
    Dump(payload.Message)

    -- Sorted according to what is used most
    if (payload.Message == "ReadChat") then
        ReadChat(playerID)
    elseif (payload.Message == "GetGroup") then
        GetGroup(playerID, payload, setReturnTable)
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
        SaveSettings(game, playerID, payload, setReturnTable)
    elseif (payload.Message == "ClearData") then
        ClearData(game, playerID)
    else
        print("unknown Server_GameCustomMessage. : " .. payload.Message)
        setReturnTable({
            Status = "unknown Server_GameCustomMessage : " .. payload.Message
        })
    end
end

function GetGroup(playerID, payload, setReturnTable)
    if payload.GroupID == nil then
        setReturnTable({Status = "Error : GroupID is missing"})
        return
    end
    -- Make sure we are a member of the group
    local group = Mod.PrivateGameData.ChatGroups[payload.GroupID]
    if group.Members[playerID] == nil then
        Dump(group.Members)
        setReturnTable({Status = "Error : You are not a member of the Group"})
        return
    end

    setReturnTable({Group = group})
end

function RemoveFromGroup(game, playerID, payload, setReturnTable)
    local playerGameData = Mod.PlayerGameData
    local TargetGroupID = payload.TargetGroupID
    local TargetPlayerID = payload.TargetPlayerID

    local group = {}
    if (playerGameData[playerID].Chat == nil or
        playerGameData[playerID].Chat[TargetGroupID] == nil) then
        -- Check if the TargetPlayerID is the owner
        print("group to be removed not found " .. TargetGroupID)
        return -- Group can't be found. Do nothing
    elseif (TargetPlayerID == playerGameData[playerID].Chat[TargetGroupID].Owner) then
        print("Can't remove the owner of a group")
        return
    else
        print("removing " .. TargetPlayerID .. " from  :" .. TargetGroupID ..
                  " ID")
        Group = playerGameData[playerID].Chat[TargetGroupID]
        removeFromSet(Group.Members, TargetPlayerID)
        playerGameData[playerID].Chat[TargetGroupID] = Group

        -- Remove the group from the playerGameData.Chat of the removed player, if it's not an AI
        if not (game.Game.Players[TargetPlayerID].IsAI) then
            if not (playerGameData[TargetPlayerID].Chat[TargetGroupID] == nil) then
                playerGameData[TargetPlayerID].Chat[TargetGroupID] = nil
            end
        end
        Mod.PlayerGameData = playerGameData
        -- Update all other group members
        UpdateAllGroupMembers(game, playerID, TargetGroupID, playerGameData)

        -- Send a chat msg to the group chat
        payload.Chat =
            game.Game.Players[TargetPlayerID].DisplayName(nil, false) ..
                " was removed from " .. Group.GroupName
        DeliverChat(game, playerID, payload, setReturnTable)
    end
end

function LeaveGroup(game, playerID, payload, setReturnTable)
    local playerGameData = Mod.PlayerGameData
    local TargetGroupID = payload.TargetGroupID
    local TargetPlayerID = playerID

    if (playerGameData[playerID].Chat == nil or
        playerGameData[playerID].Chat[TargetGroupID] == nil) then
        print("group to leave from not found " .. TargetGroupID)
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
    local playerGameData = Mod.PlayerGameData

    local TargetGroupID = payload.TargetGroupID
    local TargetPlayerID = payload.TargetPlayerID
    local TargetGroupName = payload.TargetGroupName

    print(TargetPlayerID .. " targetplayer")
    print(TargetGroupID .. " TargetGroupID")

    if (playerGameData[playerID].Chat == nil) then
        -- if nill, make an empty table where we can place GroupID
        playerGameData[playerID].Chat = {}
    end
    print("dump playerGameData[playerID].Chat")
    Dump(playerGameData[playerID].Chat)

    local Group = {}
    if (playerGameData[playerID].Chat == nil or
        playerGameData[playerID].Chat[TargetGroupID] == nil) then
        print("new group " .. TargetGroupID)
        Group = {
            Members = {},
            Owner = playerID,
            GroupName = TargetGroupName,
            GroupID = TargetGroupID,
            Color = RandomColor(),
            UnreadChat = false
        }
        AddToSet(Group.Members, playerID)
        AddToSet(Group.Members, TargetPlayerID)

        playerGameData[playerID].Chat[TargetGroupID] = Group
        UpdateAllGroupMembers(game, playerID, TargetGroupID, playerGameData)
        -- Send a msg to the chat of the group
        payload.Chat = game.Game.Players[Group.Owner].DisplayName(nil, false) ..
                           " created " .. Group.GroupName
        DeliverChat(game, playerID, payload, setReturnTable)
        payload.Chat =
            game.Game.Players[TargetPlayerID].DisplayName(nil, false) ..
                " was added to " .. Group.GroupName
        DeliverChat(game, playerID, payload, setReturnTable)
    else
        print("nice, old group :" .. TargetGroupID .. " ID")
        Group = playerGameData[playerID].Chat[TargetGroupID]

        -- Check if the player is already in the group. If so, return
        if (Group.Members[TargetPlayerID] ~= nil) then
            print(TargetPlayerID .. " is alredy in the group")
            return
        end
        -- Add the player
        AddToSet(Group.Members, TargetPlayerID)
        playerGameData[playerID].Chat[TargetGroupID] = Group
        -- Update Storage
        UpdateAllGroupMembers(game, playerID, TargetGroupID, playerGameData)
        -- Send a msg to the chat of the group
        payload.Chat =
            game.Game.Players[TargetPlayerID].DisplayName(nil, false) ..
                "  was added to " .. Group.GroupName
        DeliverChat(game, playerID, payload, setReturnTable)
    end
end

function DeliverChat(game, playerID, payload, setReturnTable)
    local playerGameData = Mod.PlayerGameData
    local data = playerGameData[playerID].Chat
    local TargetGroupID = payload.TargetGroupID

    local ChatInfo = {}
    ChatInfo.Sender = playerID
    ChatInfo.Chat = payload.Chat

    local ChatArrayIndex
    if (data[TargetGroupID] == nil) then
        ChatArrayIndex = 1
    else
        ChatArrayIndex = #data[TargetGroupID] + 1
    end

    print("Chat received " .. ChatInfo.Chat .. " to " .. TargetGroupID ..
              " from " .. ChatInfo.Sender .. " total group chat's : " ..
              ChatArrayIndex)

    -- use the ChatArrayIndex. We want the chat msg to be stored in an array	format
    if data[TargetGroupID][ChatArrayIndex] == nil then
        data[TargetGroupID][ChatArrayIndex] = {}
    end
    data[TargetGroupID].NumChat = ChatArrayIndex
    data[TargetGroupID][ChatArrayIndex] = {}
    data[TargetGroupID][ChatArrayIndex] = ChatInfo
    -- Mark the chat as unread for everyone in the group.
    data[TargetGroupID].UnreadChat = true
    playerGameData[playerID].Chat = data

    UpdateAllGroupMembers(game, playerID, TargetGroupID, playerGameData)
    local Alerts = true
    local PublicGameData = Mod.PublicGameData
    if (PublicGameData ~= nil) then
        if (PublicGameData[playerID] ~= nil) then
            Alerts = PublicGameData[playerID].AlertUnreadChat
        end
    end
    if (Alerts) then setReturnTable({Status = "Chat sent"}) end
end

function ReadChat(playerID)
    local playerGameData = Mod.PlayerGameData
    -- Mark chat as read
    for i, v in pairs(playerGameData[playerID].Chat) do
        playerGameData[playerID].Chat[i].UnreadChat = false
    end
    Mod.PlayerGameData = playerGameData
end

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

function DeleteGroup(game, playerID, payload, setReturnTable)
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

function SaveSettings(game, playerID, payload, setReturnTable)

    -- Validate settings
    local AlertUnreadChat = payload.AlertUnreadChat or true
    local NumPastChat = payload.NumPastChat or 7
    local MenuSizeX = payload.MenuSizeX or 550
    local MenuSizeY = payload.MenuSizeY or 550

    -- Save settings
    local PlayerGameData = Mod.PlayerGameData
    if (PlayerGameData == nil) then PlayerGameData = {} end
    if (PlayerGameData[playerID] == nil) then PlayerGameData[playerID] = {} end

    PlayerGameData[playerID].Settings = {
        AlertUnreadChat = AlertUnreadChat,
        NumPastChat = NumPastChat,
        MenuSizeX = MenuSizeX,
        MenuSizeY = MenuSizeY
    }
    Mod.PlayerGameData[playerID] = PlayerGameData
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

