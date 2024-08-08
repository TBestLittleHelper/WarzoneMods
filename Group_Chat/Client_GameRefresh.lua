require("Utilities")

function Client_GameRefresh(game)
    -- Skip if we're not in the game or if the game is over.
    if (game.Us == nil or Mod.PublicGameData.GameFinalized) then return end
    print("client game refresh")
    if (Mod.PublicGameData == nil) then return end

    -- Check for unread chat
    print("Checking unread chat")
    CheckUnreadChat(game)
end

-- Alert when new chat.
function CheckUnreadChat(game)
    if (skipRefresh == nil or skipRefresh == true) then return end

    local PlayerGameData = Mod.PlayerGameData
    if (PlayerGameData.Chat == nil) then
        print("PlayerGameData.Chat is nil. No unread chat")
        return
    end

    local alertMsg = " Alert message" -- todo add alertMsg
    -- Check if alerts are true
    local Alerts = Mod.PlayerGameData.Settings.AlertUnreadChat or true
    -- todo extract get settings to it's own file and use here?

    for _, groupID in pairs(PlayerGameData.ChatGroupMember) do
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
