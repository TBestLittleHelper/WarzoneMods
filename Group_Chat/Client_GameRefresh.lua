require("Utilities")

local UnreadMessages;
function Client_GameRefresh(game)
    print(skipRefresh, "skipRefresh")
    -- Skip if we're not in the game or if the game is over.
    if (game.Us == nil or Mod.PublicGameData.GameFinalized) then return end
    if (SkipRefresh) then return end -- skipRefresh might be nill

    if Mod.PlayerGameData.Settings and
        Mod.PlayerGameData.Settings.AlertUnreadChat ~= nil then
        if Mod.PlayerGameData.Settings.AlertUnreadChat then
            CheckUnreadChat(game)
        end
    else
        CheckUnreadChat(game)
    end
end
function UnreadChatDialog(rootParent, setMaxSize, setScrollable, game, close)
    setMaxSize(410, 390) -- This dialog's size

    local vert = UI.CreateVerticalLayoutGroup(rootParent)
    UI.CreateLabel(vert).SetText("Last chat messages")

    local horizontalLayout = UI.CreateHorizontalLayoutGroup(vert)

    for _, group in ipairs(UnreadMessages) do
        print("here ----- ")
        UI.CreateButton(horizontalLayout).SetText(group.Name)
        UI.CreateButton(horizontalLayout).SetText(group.SenderID)
        UI.CreateButton(horizontalLayout).SetText(group.Chat)
    end
end

-- Alert when new chat.
function CheckUnreadChat(game)
    local PlayerGameData = Mod.PlayerGameData
    local unreadMessages;

    for groupID, group in pairs(PlayerGameData.ChatGroupMember) do
        if (group.UnreadChat ~= nil) then
            unreadMessages[groupID] = {
                SenderID = group.UnreadChat.SenderID,
                Chat = group.UnreadChat.Chat,
                Name = group.Name
            }
        end
    end
    if unreadMessages ~= nil then
        -- todo Improve markChatAsRead code
        SkipRefresh = true
        local payload = {Message = "ReadChat"}
        game.SendGameCustomMessage("Marking chat as read...", payload,
                                   function(returnValue)
            if returnValue.Status ~= nil then
                UI.Alert(returnValue.Status)
                return
            end
        end)
        UnreadMessages = unreadMessages
        game.CreateDialog(UnreadChatDialog)
    end
end
