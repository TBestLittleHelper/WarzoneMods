require("Utilities")
require("Client_EditDialog")

local ClientGame;
local PlayerGameData;
local SkipRefresh = false;

-- UI Values
local CurrentGroupID;
local CurrentGroup;
local CurrentChatHistory;
local PlayerSettings;

-- UI Elements
local GroupMembersNames;
local ChatLayout;
local ChatContainer;
local ChatMessageText;
local ChatMsgContainerArray;

-- Settings
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    if (Mod.Settings.Version < 1) then
        UI.Alert(
            "This game was created using an older version of the mod. Things might not work.")
    end

    if (Mod.PublicGameData.GameFinalized == false) then
        -- Check if the game has ended.
        -- We need to check here and not in ServerAdvanceTurn. Since VTE is not detectable there
        CheckGameEnded(game)
        -- todo improve this
    end

    -- If a spectator, just alert then return
    if (game.Us == nil and Mod.PublicGameData.GameFinalized == false) then
        UI.Alert(
            "You can't do anything as a spectator until the game has ended.")
        return
    end

    ClientGame = game
    PlayerGameData = Mod.PlayerGameData

    SkipRefresh = false -- This is set to true if we go to Edit or Settings Dialog

    print("Client_PresentMenuUI")
    PlayerSettings = GetSettings();
    Dump(PlayerSettings)
    local groupID, _ = next(PlayerGameData.ChatGroupMember)
    CurrentGroupID = groupID

    setMaxSize(PlayerSettings.MenuSizeX, PlayerSettings.MenuSizeY)
    setScrollable(false, true)

    ChatLayout = nil
    ChatContainer = nil
    ChatMsgContainerArray = {}

    -- Setting up the main UI Dialog window

    -- Make a label to list members of the current selected group.
    GroupMembersNames = UI.CreateLabel(rootParent)

    local vert = UI.CreateVerticalLayoutGroup(rootParent)
    local horizontalLayout = UI.CreateHorizontalLayoutGroup(vert)

    -- Edit group button
    UI.CreateButton(horizontalLayout).SetText("Edit groups").SetFlexibleWidth(
        0.2).SetOnClick(function()
        if (ChatMsgContainerArray ~= {}) then
            DestroyOldUIelements(ChatMsgContainerArray)
        end
        SkipRefresh = true
        print("CreateGroupEditDialog")
        ClientGame.CreateDialog(CreateGroupEditDialog)
        close() -- Close this dialog.
    end)

    -- If we are in a group, show the chat options
    if (PlayerGameData.ChatGroupMember ~= nil) then
        -- For all groups, show a button
        for memberGroupID, playerGroup in pairs(PlayerGameData.ChatGroupMember) do
            print("member of group : ", playerGroup.Name, memberGroupID)
            UI.CreateButton(horizontalLayout).SetText(playerGroup.Name)
                .SetColor(playerGroup.Color).SetOnClick(function()
                CurrentGroupID = memberGroupID
                RefreshGroup()
            end)
        end
    end
    ChatContainer = UI.CreateVerticalLayoutGroup(vert)

    ChatMessageText = UI.CreateTextInputField(vert).SetPlaceholderText(
                          " Max 300 characters in one messages")
                          .SetFlexibleWidth(0.9).SetCharacterLimit(300)
                          .SetPreferredWidth(500).SetPreferredHeight(40)

    local RefreshSendButtonContainer = UI.CreateHorizontalLayoutGroup(vert)
    -- RefreshChat button
    UI.CreateButton(RefreshSendButtonContainer).SetText("Refresh chat")
        .SetColor("#00ff05").SetOnClick(RefreshGroup)
    -- Send chat button
    UI.CreateButton(RefreshSendButtonContainer).SetColor("#880085").SetText(
        "Send chat").SetOnClick(function()
        if (CurrentGroupID == nil) then
            UI.Alert("Pick a chat group first")
            return
        end
        if (string.len(ChatMessageText.GetText()) < 2 or
            ChatMessageText.GetText() == ChatMessageText.GetPlaceholderText()) then
            UI.Alert("A chat msg must be more then 1 characters")
            return
        end
        SendChat()
    end)
    -- Settings button
    UI.CreateButton(rootParent).SetText("Settings").SetColor("#00ff05")
        .SetOnClick(function()
        if (ChatMsgContainerArray ~= {}) then
            DestroyOldUIelements(ChatMsgContainerArray)
        end
        SkipRefresh = true
        ClientGame.CreateDialog(SettingsDialog)
        close() -- Close this dialog.
    end)

    RefreshGroup()
end

function SettingsDialog(rootParent, setMaxSize, setScrollable, game, close)
    setMaxSize(410, 390) -- This dialog's size
    local vert = UI.CreateVerticalLayoutGroup(rootParent)

    -- Alert user of unread chat
    AlertUnreadChatCheckBox = UI.CreateCheckBox(vert).SetIsChecked(
                                  PlayerSettings.AlertUnreadChat)
                                  .SetText("Alert for new chat")

    -- Num of max past chat shown
    UI.CreateLabel(vert).SetText("Visible chat messages")
    NumPastChatInput = UI.CreateNumberInputField(vert).SetSliderMinValue(3)
                           .SetSliderMaxValue(100)
                           .SetValue(PlayerSettings.NumPastChat)

    -- Let's the user use setMaxSize for the main dialog
    UI.CreateLabel(vert).SetText("Change X size")
    SizeXInput = UI.CreateNumberInputField(vert).SetSliderMinValue(300)
                     .SetSliderMaxValue(1000).SetValue(PlayerSettings.MenuSizeX)
    UI.CreateLabel(vert).SetText("Change Y size")
    SizeYInput = UI.CreateNumberInputField(vert).SetSliderMinValue(300)
                     .SetSliderMaxValue(1000).SetValue(PlayerSettings.MenuSizeY)

    local buttonRow = UI.CreateHorizontalLayoutGroup(vert)
    -- Go back to PresentMenuUI button : don't save
    UI.CreateButton(buttonRow).SetText("Go Back").SetColor("#0000FF")
        .SetOnClick(function() RefreshMainDialog(close) end)

    -- Save changes then go back to MainDialog
    ResizeChatDialog = UI.CreateButton(buttonRow).SetText("Save settings")
                           .SetColor("#00ff05").SetOnClick(function()
        SaveSettingsGoMainDialog(AlertUnreadChatCheckBox.GetIsChecked(),
                                 NumPastChatInput.GetValue(),
                                 SizeXInput.GetValue(), SizeYInput.GetValue(),
                                 close)
    end)
end

function GetSettings()
    print("GetSettings")
    -- If PlayerGameData is not updated, the local player settings may be newer
    if (PlayerSettings ~= nil and Mod.PlayerGameData.Settings ~= nil) then
        if (PlayerSettings.TickCount > Mod.PlayerGameData.Settings.TickCount) then
            return PlayerSettings
        end
    end
    PlayerSettings = Mod.PlayerGameData.Settings or {}
    return {
        AlertUnreadChat = (PlayerSettings.AlertUnreadChat ~= nil) and
            PlayerSettings.AlertUnreadChat or true,
        NumPastChat = PlayerSettings.NumPastChat or 7,
        MenuSizeX = PlayerSettings.MenuSizeX or 550,
        MenuSizeY = PlayerSettings.MenuSizeY or 550,
        TickCount = PlayerSettings.TickCount or 0
    }
end

function SaveSettingsGoMainDialog(AlertUnreadChat, NumPastChat, MenuSizeX,
                                  MenuSizeY, close)
    -- Save settings serverside
    local payload = {
        Message = "SaveSettings",
        AlertUnreadChat = AlertUnreadChat,
        NumPastChat = NumPastChat,
        MenuSizeX = MenuSizeX,
        MenuSizeY = MenuSizeY
    }
    ClientGame.SendGameCustomMessage("Saving settings...", payload,
                                     function(returnValue)
        if returnValue.Status ~= nil then
            UI.Alert(returnValue.Status)
            return
        end
        local function SetSettings(settings)
            print("SetSettings")
            Dump(settings)
            PlayerSettings = {
                AlertUnreadChat = (settings.AlertUnreadChat ~= nil) and
                    settings.AlertUnreadChat or true,
                NumPastChat = settings.NumPastChat or 7,
                MenuSizeX = settings.MenuSizeX or 550,
                MenuSizeY = settings.MenuSizeY or 550,
                TickCount = WL.TickCount()
            }
        end
        SetSettings(returnValue.Settings)
        RefreshMainDialog(close)
    end)
end

function RefreshMainDialog(close)
    print("RefreshMainDialog", close)
    if close ~= nil then close() end

    if (MainDialog ~= nil) then
        UI.Destroy(MainDialog)
        print("destroyed old dialog")
    end

    print("Open ClientDialog")
    SkipRefresh = false
    MainDialog = ClientGame.CreateDialog(Client_PresentMenuUI)
end

function ChatGroupSelected()
    local groups = {}
    for i, v in pairs(PlayerGameData.ChatGroupMember) do
        groups[i] = PlayerGameData.ChatGroupMember[i]
    end
    local options = map(groups, ChatGroupSelectedButton)
    UI.PromptFromList("Select a chat group", options)
end

function ChatGroupSelectedButton(group)
    local name = group.GroupName
    local ret = {}
    ret["text"] = name
    ret["selected"] = function()
        ChatGroupSelectedText.SetText(name).SetColor(group.Color)
        ChatGroupSelectedID = group.GroupID

        RefreshGroup()
    end
    return ret
end

function SendChat()
    local payload = {}
    payload.Message = "SendChat"
    payload.TargetGroupID = CurrentGroupID
    payload.Chat = ChatMessageText.GetText()
    ClientGame.SendGameCustomMessage("Sending chat...", payload,
                                     function(returnValue)
        if returnValue.Status ~= nil then
            UI.Alert(returnValue.Status)
            return
        end
    end)
    ChatMessageText.SetText("")
    RefreshGroup()
end

function RefreshGroup()
    if (SkipRefresh) then
        print("skipRefresh chat")
        return
    end
    if (CurrentGroupID == nil) then
        print("RefreshChat skipped, no CurrentGroupID")
        return
    end
    GetGroupPrivateGameData()
end
function GetGroupPrivateGameData()
    local payload = {Message = "GetGroup", GroupID = CurrentGroupID}
    ClientGame.SendGameCustomMessage("Getting group from the server...",
                                     payload, function(returnValue)
        if returnValue.Status ~= nil then
            UI.Alert(returnValue.Status)
            return
        end
        CurrentGroup = returnValue.Group
        UpdateMainDialogUI()
    end)
end

function UpdateMainDialogUI()
    if (CurrentGroup == nil) then
        print("UpdateMainDialogUI skipped, no CurrentGroup")
        return
    end

    -- Update the members of the current selected group.
    GroupMembersNames.SetText(GroupMembersString(CurrentGroup.Members))

    -- todo test Remove old elements
    DestroyOldUIelements(ChatMsgContainerArray)

    local rowChatRecived = UI.CreateVerticalLayoutGroup(ChatContainer)
    ChatLayout = UI.CreateVerticalLayoutGroup(rowChatRecived)

    table.insert(ChatMsgContainerArray, rowChatRecived)
    table.insert(ChatMsgContainerArray, ChatLayout)

    local horzMain = UI.CreateVerticalLayoutGroup(ChatLayout)

    ChatMessageText.SetInteractable(true)

    -- TODO use settings for num chat
    local startIndex = 1
    if (#CurrentGroup.ChatHistory > PlayerSettings.NumPastChat) then
        startIndex = #CurrentGroup.ChatHistory -
                         (PlayerSettings.NumPastChat - 1)
    end

    for i = startIndex, #CurrentGroup.ChatHistory do
        print(" current i ", i)
        local horz = UI.CreateHorizontalLayoutGroup(horzMain)

        -- Chat Sender
        local ChatSenderButton = UI.CreateButton(horz).SetPreferredWidth(150)
                                     .SetPreferredHeight(8)
        if (CurrentGroup.ChatHistory[i].SenderID == -1) then
            ChatSenderButton.SetText("Mod Info").SetColor("#880085")
        else
            ChatSenderButton.SetText(
                ClientGame.Game.Players[CurrentGroup.ChatHistory[i].SenderID]
                    .DisplayName(nil, false)).SetColor(
                ClientGame.Game.Players[CurrentGroup.ChatHistory[i].SenderID]
                    .Color.HtmlColor)
        end
        -- Chat messages
        UI.CreateLabel(horz).SetFlexibleWidth(1).SetFlexibleHeight(1).SetText(
            CurrentGroup.ChatHistory[i].Chat)
    end
end

function GroupMembersString(members)
    local displayString = ""
    for playerID, _ in pairs(members) do
        displayString = displayString .. " " ..
                            ClientGame.Game.Players[playerID]
                                .DisplayName(nil, false)
    end

    return displayString
end

function DestroyOldUIelements(Container)
    if (next(Container) ~= nil) then
        for count = #Container, 1, -1 do
            if (Container[count] ~= nil) then
                UI.Destroy(Container[count])
            end
            table.remove(Container, count)
        end
    end
end

function TargetGroupClicked()
    print("TargetGroupClicked")

    local groups = {}
    for i, _ in pairs(PlayerGameData.ChatGroupMember) do
        print(i)
        groups[i] = PlayerGameData.ChatGroupMember[i]
    end
    local options = map(groups, GroupButton)
    UI.PromptFromList("Select the group you'd like to add this player too",
                      options)
end

function CheckGameEnded(game)
    -- 3 == playing : 4 == elim + over , 5 == manual picks
    print("Game.state code:" .. game.Game.State)
    if (game.Us == nil) then return end -- Return if spectator
    if (game.Game.State ~= 4) then return end

    local payload = {}
    payload.Message = "ClearData"
    game.SendGameCustomMessage("Clearing mod data...", payload,
                               function(returnValue) end)
end

