require("Utilities")

function Client_GameRefresh(game)
    -- Skip if we're not in the game or if the game is over.
    if (game.Us == nil or Mod.PublicGameData.GameFinalized) then return end
    if (skipRefresh == nil or skipRefresh == true) then return end

    if (Mod.PlayerGameData.Settings.AlertUnreadChat) then
        CheckUnreadChat(game)
    end
end

-- Alert when new chat.
function CheckUnreadChat(game)
    print("Checking unread chat", skipRefresh)
    local PlayerGameData = Mod.PlayerGameData

    -- todo extract get settings to it's own file and use here?
    print("2222Checking unread chat")

    for _, groupID in pairs(PlayerGameData.ChatGroupMember) do
        print("CheckUnreadChat ", groupID)

        local group = PlayerGameData.ChatGroupMember[groupID]
        -- Always alert in SP, for testing
        if (group.UnreadChat ~= nil) then
            if (Alerts) then
                -- Last message from group
                local lastChat = group.UnreadChat.Chat
                local SenderID = group.UnreadChat.SenderID

                UI.Alert(lastChat .. SenderID)

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
