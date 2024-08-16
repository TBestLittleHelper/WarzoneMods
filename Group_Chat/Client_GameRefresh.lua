require("Utilities")
require("Client_AlertDialog")

local UnreadMessages;
local LastRefresh;
function Client_GameRefresh(game)
    -- Skip if we're not in the game or if the game is over.
    if (game.Us == nil or Mod.PublicGameData.GameFinalized) then return end

    -- If we recently refreshed, don't do it again!
    if (LastRefresh == nil) then
        LastRefresh = WL.TickCount()
        -- 6000 is 10 seconds
    elseif (LastRefresh + 6000 > WL.TickCount()) then
        print("Last refesh was too recent!")
        print(WL.TickCount() - LastRefresh)
        return
    end
    LastRefresh = WL.TickCount()

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

    for _, group in pairs(UnreadMessages) do
        Dump(group)
        UI.CreateButton(horizontalLayout).SetText(group.Name).SetColor(
            group.Color)
        UI.CreateButton(horizontalLayout).SetText(
            game.Game.Players[group.SenderID].DisplayName(nil, false)).SetColor(
            game.Game.Players[group.SenderID].Color.HtmlColor)
        UI.CreateLabel(horizontalLayout).SetText(group.Chat)
    end
end

-- Alert when new chat.
function CheckUnreadChat(game)
    local PlayerGameData = Mod.PlayerGameData
    local unreadMessages = {};

    for groupID, group in pairs(PlayerGameData.ChatGroupMember) do
        if (group.UnreadChat) then
            Dump(group.UnreadChat)
            unreadMessages[groupID] = {
                SenderID = group.UnreadChat.SenderID,
                Chat = group.UnreadChat.Chat,
                Name = group.Name,
                Color = group.Color
            }
        end
    end
    if next(unreadMessages) then
        -- todo Improve markChatAsRead code
        local payload = {Message = "ReadChat"}
        game.SendGameCustomMessage("Marking chat as read...", payload, function(
            returnValue) Alert(returnValue.Status, game) end)
        UnreadMessages = unreadMessages
        game.CreateDialog(UnreadChatDialog)
    end
end
