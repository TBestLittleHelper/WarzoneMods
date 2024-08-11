require("Utilities")

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

    -- Manage group button
    UI.CreateButton(horizontalLayout).SetText("Manage groups").SetFlexibleWidth(
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
            print("member of group : ", playerGroup.Name)
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

    local RefreshChatButtonContainer = UI.CreateHorizontalLayoutGroup(vert)
    -- RefreshChat button
    UI.CreateButton(RefreshChatButtonContainer).SetText("Refresh chat")
        .SetColor("#00ff05").SetOnClick(RefreshGroup)
    -- local color = ClientGame.Game.Players[ClientGame.Us.ID].Color.HtmlColor -- Let's color the send chat button in the users color
    -- Send chat button
    UI.CreateButton(RefreshChatButtonContainer).SetColor("#880085").SetText(
        "Send chat").SetOnClick(function()
        if (ChatGroupSelectedID == nil) then
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
    if (PlayerSettings ~= nil) then
        -- If PlayerGameData is not updated, the local playersettings may be newer
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

        -- todo GroupMembersNames.SetText(GetGroupMembers())
        RefreshGroup()
    end
    return ret
end

function CreateGroupEditDialog(rootParent, setMaxSize, setScrollable, game,
                               close)
    setMaxSize(420, 330)
    TargetPlayerID = nil
    TargetGroupID = nil

    local vert = UI.CreateVerticalLayoutGroup(rootParent)
    local row1 = UI.CreateHorizontalLayoutGroup(vert)
    UI.CreateLabel(row1).SetText(
        "Select a player to add or remove from a group: ")
    TargetPlayerBtn = UI.CreateButton(row1).SetText("Select player...")
                          .SetColor(RandomColor())
                          .SetOnClick(TargetPlayerClicked)

    local row11 = UI.CreateHorizontalLayoutGroup(vert)
    GroupTextNameLabel = UI.CreateLabel(row11)
                             .SetText("Name a new chat group: ")
    GroupTextName = UI.CreateTextInputField(row11).SetCharacterLimit(25)
                        .SetPlaceholderText(" Group Name max 25 characters")
                        .SetPreferredWidth(200).SetFlexibleWidth(1)

    local row2 = UI.CreateHorizontalLayoutGroup(vert)
    print("here CreateGroupEditDialog", PlayerGameData,
          PlayerGameData.ChatGroupMember)
    print("dump PlayerGameData")
    Dump(PlayerGameData)
    if (next(PlayerGameData.ChatGroupMember) ~= nil) then
        ChatGroupBtn = UI.CreateButton(row2).SetText("Pick an existing group")
                           .SetOnClick(ChatGroupClicked)
    end
    -- Add a player to a group
    UI.CreateButton(row2).SetText("Add Player").SetColor("#00ff05").SetOnClick(
        function()
            if (TargetPlayerID == nil) then
                UI.Alert("Please choose a player first")
                return
            end
            if (GroupTextName.GetText() == nil or
                string.len(GroupTextName.GetText()) < 3) then
                UI.Alert("Please choose a group name with at least 3 characters")
                return
            end

            if (TargetGroupID == nil) then
                TargetGroupID = WL.TickCount()
                print("makeing new groupID: " .. TargetGroupID)
            else
                print("found old group ID " .. TargetPlayerID)
            end

            local payload = {}
            payload.Message = "AddGroupMember"
            payload.TargetPlayerID = TargetPlayerID
            payload.TargetGroupID = TargetGroupID
            payload.TargetGroupName = GroupTextName.GetText()

            ClientGame.SendGameCustomMessage("Adding group member...", payload,
                                             function(returnValue)
                TargetPlayerBtn.SetText("Select player...")
                    .SetColor(RandomColor())
                TargetPlayerID = nil -- Reset
                GroupTextName.SetInteractable(false) -- We store the GroupID, so don't let the user change the name
            end)
        end)

    -- Remove a player from a group
    UI.CreateButton(row2).SetText("Remove Player").SetColor("#FF0000")
        .SetOnClick(function()
        if (TargetPlayerID == nil) then
            UI.Alert("Please choose a player first")
            return
        end
        -- If GroupTextName.GetInteractable is false, we know that TargetGroupID is set
        if (GroupTextName.GetInteractable() == true) then
            UI.Alert("Please choose a group from the list")
            return
        end
        -- We can't remove the owner of a group
        if (TargetPlayerID == Mod.PlayerGameData.Chat[TargetGroupID].Owner) then
            UI.Alert("You can't remove the owner of a group")
            return
        end

        local payload = {}
        payload.Mod = "Chat"
        payload.Message = "RemoveGroupMember"
        payload.TargetPlayerID = TargetPlayerID
        payload.TargetGroupID = TargetGroupID

        ClientGame.SendGameCustomMessage("Removing group member...", payload,
                                         function(returnValue)
            TargetPlayerBtn.SetText("Select player...").SetColor(RandomColor())
            TargetPlayerID = nil -- Reset
        end)
    end)

    local buttonRow = UI.CreateHorizontalLayoutGroup(vert)
    -- Go back to PresentMenuUi button
    UI.CreateButton(buttonRow).SetText("Go Back").SetColor("#0000FF")
        .SetOnClick(function() RefreshMainDialog(close) end)

    -- Leave a group option
    LeaveGroupBtn = UI.CreateButton(buttonRow).SetText("Leave group")
                        .SetInteractable(false).SetColor("#FF0000")
                        .SetOnClick(function()
        -- If GroupTextName.GetInteractable is false, we know that TargetGroupID is set
        if (GroupTextName.GetInteractable() == true) then
            UI.Alert("Please choose a group from the list")
            return
        end
        if (Mod.PlayerGameData.Chat[TargetGroupID].Owner == ClientGame.Us.ID) then
            UI.Alert(
                "You can't leave a group you created. You can, however delete the group.")
            return
        end
        local payload = {}
        payload.Mod = "Chat"
        payload.Message = "LeaveGroup"
        payload.TargetGroupID = TargetGroupID
        ClientGame.SendGameCustomMessage("Leaving the group...", payload,
                                         function(returnValue)
            -- Reset Group Selected
            TargetGroupID = nil
            GroupTextName.SetText("").SetInteractable(true)
        end)
    end)

    -- Delete a group : only possible as a group owner
    local deleteGroupBtn = UI.CreateButton(buttonRow).SetText("Delete group")
                               .SetInteractable(false).SetColor("#FF0000")
                               .SetOnClick(function()
        -- If GroupTextName.GetInteractable is false, we know that TargetGroupID is set
        if (GroupTextName.GetInteractable() == true) then
            UI.Alert("Please choose a group from the list")
            return
        end

        if (Mod.PlayerGameData.Chat[TargetGroupID].Owner ~= ClientGame.Us.ID) then
            UI.Alert("You can only delete if you are the owner of a group")
            return
        end

        local payload = {}
        payload.Mod = "Chat"
        payload.Message = "DeleteGroup"
        payload.TargetGroupID = TargetGroupID

        -- Ask for confirmation from the player
        UI.PromptFromList("Are you sure you want to delete " ..
                              Mod.PlayerGameData.Chat[TargetGroupID].GroupName ..
                              "?", {
            DeleteGroupConfirmed(ClientGame, payload), DeleteGroupDeclined()
        })
    end)
end

function SendChat()
    local payload = {}
    payload.Mod = "Chat"
    payload.Message = "SendChat"
    payload.TargetGroupID = ChatGroupSelectedID
    payload.Chat = ChatMessageText.GetText()
    print("Chat sent " .. payload.Chat .. " to " .. payload.TargetGroupID ..
              " from " .. ClientGame.Us.ID)
    ClientGame.SendGameCustomMessage("Sending chat...", payload,
                                     function(returnValue)
        if returnValue.Status ~= nil then
            UI.Alert(returnValue.Status)
            return
        end
    end)
    ChatMessageText.SetText("")
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
    GroupMembersNames.SetText(GroupMembersString(CurrentGroup))

    -- Remove old elements todo
    DestroyOldUIelements(ChatMsgContainerArray)

    local rowChatRecived = UI.CreateVerticalLayoutGroup(ChatContainer)
    ChatLayout = UI.CreateVerticalLayoutGroup(rowChatRecived)

    table.insert(ChatMsgContainerArray, rowChatRecived)
    table.insert(ChatMsgContainerArray, ChatLayout)

    local horzMain = UI.CreateVerticalLayoutGroup(ChatLayout)

    ChatMessageText.SetInteractable(true)

    -- TODO use settings for num chat
    for i = 1, #CurrentGroup.ChatHistory do
        local horz = UI.CreateHorizontalLayoutGroup(horzMain)

        -- Chat Sender
        local ChatSenderbtn = UI.CreateButton(horz).SetPreferredWidth(150)
                                  .SetPreferredHeight(8)
        if (CurrentGroup.ChatHistory[i].SenderID == -1) then
            ChatSenderbtn.SetText("Mod Info").SetColor("#880085")
        else
            ChatSenderbtn.SetText(
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

function GroupMembersString(group)
    -- todo all members
    local playerID = next(group.Members)
    local player = ClientGame.Game.Players[playerID]
    local displayName = player.DisplayName(nil, false)

    return displayName
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

function TargetPlayerClicked()
    local options = Map(Filter(ClientGame.Game.Players, IsPotentialTarget),
                        PlayerButton)
    UI.PromptFromList(
        "Select the player you'd like to add or remove from a group", options)
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

function PlayerButton(player)
    local name = player.DisplayName(nil, false)

    local ret = {}
    ret["text"] = name
    ret["selected"] = function()
        TargetPlayerBtn.SetText(name).SetColor(player.Color.HtmlColor)
        TargetPlayerID = player.ID
    end
    return ret
end

function GroupButton(group)
    local name = group.GroupName

    local ret = {}
    ret["text"] = name
    ret["selected"] = function()
        GroupTextName.SetText(name).SetInteractable(false)
        TargetGroupID = group.Owner
    end
    return ret
end

function ChatGroupClicked()
    local groups = {}
    PlayerGameData = Mod.PlayerGameData -- Make sure we have the latest PlayerGameData
    for i, _ in pairs(PlayerGameData.ChatGroupMember) do
        print(i)
        groups[i] = PlayerGameData.ChatGroupMember[i]
    end
    local options = map(groups, ChatGroupButton)
    UI.PromptFromList("Select a chat group", options)
end
function ChatGroupButton(group)
    local name = group.GroupName
    local ret = {}
    ret["text"] = name
    ret["selected"] = function()
        GroupTextName.SetText(name).SetInteractable(false)
        TargetGroupID = group.GroupID
        GroupTextNameLabel.SetText("Selected group ")
        -- Check if we are owner or member
        if (ClientGame.Us.ID == Mod.PlayerGameData.Chat[TargetGroupID].Owner) then
            -- If we are the owner, we can delete the group
            deleteGroupBtn.SetInteractable(true)
            LeaveGroupBtn.SetInteractable(false)
        else
            -- If we are not the owner we can leave the group
            deleteGroupBtn.SetInteractable(false)
            LeaveGroupBtn.SetInteractable(true)
        end
    end
    return ret
end

function DeleteGroupConfirmed(ClientGame, payload)
    local ret = {}
    ret["text"] = "Yes, delete the group"
    ret["selected"] = function()
        ClientGame.SendGameCustomMessage("Deleting group...", payload,
                                         function(returnValue) end)
        -- Reset Group Selected
        TargetGroupID = nil
        ChatGroupSelectedID = nil
        GroupTextName.SetText("").SetInteractable(true)
    end
    return ret
end

function DeleteGroupDeclined()
    local ret = {}
    ret["text"] = "No."
    ret["selected"] = function() end
    return ret
end

-- Determins if the player is one we can interact with.
function IsPotentialTarget(player)
    if (ClientGame.Us.ID == player.ID) then return false end -- we can never add ourselves.

    if (player.State ~= WL.GamePlayerState.Playing) then return false end -- skip players not alive anymore, or that declined the game.

    if (ClientGame.Settings.SinglePlayer) then return true end -- in single player, allow proposing with everyone

    return not player.IsAI -- In multi-player, never allow adding an AI.
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

