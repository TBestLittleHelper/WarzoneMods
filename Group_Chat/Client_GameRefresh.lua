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
    print("testDialog")
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
    print("Checking unread chat")
    local PlayerGameData = Mod.PlayerGameData

    UnreadMessages = {}

    for groupID, group in pairs(PlayerGameData.ChatGroupMember) do
        --   Dump(groupID)
        print(groupID, "groupID")
        Dump(group)
        print("CheckUnreadChat ", groupID)

        --        local group = PlayerGameData.ChatGroupMember[groupID]
        if (group.UnreadChat ~= nil) then
            UnreadMessages[groupID] = {
                SenderID = group.UnreadChat.SenderID,
                Chat = group.UnreadChat.Chat,
                Name = group.Name
            }
        end
    end
    if UnreadMessages ~= {} then
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
        game.CreateDialog(UnreadChatDialog)
    end
end
