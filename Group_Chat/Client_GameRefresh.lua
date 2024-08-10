require("Utilities")

function Client_GameRefresh(game)
    -- Skip if we're not in the game or if the game is over.
    if (game.Us == nil or Mod.PublicGameData.GameFinalized) then return end

    CheckUnreadChat(game)
end

-- Alert when new chat.
function CheckUnreadChat(game)
    print("Checking unread chat", skipRefresh)

    if (skipRefresh == nil or skipRefresh == true) then return end

    local PlayerGameData = Mod.PlayerGameData

    local alertMsg = " Alert message" -- todo add alertMsg
    -- Check if alerts are true
    local Alerts = Mod.PlayerGameData.Settings.AlertUnreadChat or true
    -- todo extract get settings to it's own file and use here?
    print("2222Checking unread chat")

    for _, groupID in pairs(PlayerGameData.ChatGroupMember) do
        print("CheckUnreadChat ", groupID)

        local group = PlayerGameData.ChatGroupMember[groupID]
        -- Always alert in SP, for testing
        if (group.UnreadChat == true or game.Settings.SinglePlayer == true) then
            if (Alerts) then
                local sender = "Mod Info"
                -- TODO add sender name?

                alertMsg = alertMsg .. group.Name .. " has unread chat."
                UI.Alert(alertMsg)
                -- todo Maybe improve markChatAsRead code
                local payload = {}
                payload.Mod = "Chat"
                payload.Message = "ReadChat"
                payload.GroupID = groupID
                game.SendGameCustomMessage("Marking chat as read...", payload,
                                           function(returnValue)
                    if returnValue.Status ~= nil then
                        UI.Alert(returnValue.Status)
                        return
                    end
                end)
            end
        end
    end
end
