require("Utilities")

local ClientGame;

-- todo UI name and var as local here

function CreateGroupEditDialog(rootParent, setMaxSize, setScrollable, game,
                               close)

    local playerGameData = Mod.PlayerGameData
    ClientGame = game

    setMaxSize(420, 330)
    TargetPlayerID = nil
    TargetGroupID = nil

    local vert = UI.CreateVerticalLayoutGroup(rootParent)
    local row1 = UI.CreateHorizontalLayoutGroup(vert)
    UI.CreateLabel(row1).SetText("Player: ")
    TargetPlayerBtn = UI.CreateButton(row1).SetText("Select player...")
                          .SetColor(RandomColor())
                          .SetOnClick(TargetPlayerClicked)

    local row11 = UI.CreateHorizontalLayoutGroup(vert)
    GroupTextNameLabel = UI.CreateLabel(row11).SetText("Group name: ")
    GroupTextName = UI.CreateTextInputField(row11).SetCharacterLimit(25)
                        .SetPlaceholderText("Max 25 characters")
                        .SetPreferredWidth(200).SetFlexibleWidth(1)

    GroupColorButton = UI.CreateButton(row11).SetText("Color").SetColor(
                           RandomColor()).SetOnClick(GroupColorClicked)

    local row2 = UI.CreateHorizontalLayoutGroup(vert)
    if (next(playerGameData.ChatGroupMember) ~= nil) then
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
            end

            local payload = {}
            payload.Message = "AddGroupMember"
            payload.TargetPlayerID = TargetPlayerID
            payload.TargetGroupID = TargetGroupID
            payload.TargetGroupName = GroupTextName.GetText()
            payload.Color = GroupColorButton.GetColor()

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
        if (TargetPlayerID ==
            Mod.PlayerGameData.ChatGroupMember[TargetGroupID].Owner) then
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

    -- Leave group option
    LeaveGroupButton = UI.CreateButton(buttonRow).SetText("Leave group")
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
    DeleteGroupButton = UI.CreateButton(buttonRow).SetText("Delete group")
                            .SetInteractable(false).SetColor("#FF0000")
                            .SetOnClick(function()
        -- If GroupTextName.GetInteractable is false, we know that TargetGroupID is set
        if (GroupTextName.GetInteractable() == true) then
            UI.Alert("Please choose a group from the list")
            return
        end

        if (Mod.PlayerGameData.Chat[TargetGroupID].OwnerID ~= ClientGame.Us.ID) then
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

function ChatGroupButton(group)
    Dump(group)
    local name = group.Name
    local ret = {}
    ret["text"] = name
    ret["selected"] = function()
        GroupTextName.SetText(name).SetInteractable(false)
        -- Set color to match the current group, and don't allow changing it
        GroupColorButton.SetColor(group.Color)
        GroupColorButton.SetOnClick(function() end)
        TargetGroupID = group.GroupID

        -- Check if we are owner or member
        if (ClientGame.Us.ID == group.OwnerID) then
            -- If we are the owner, we can delete the group
            DeleteGroupButton.SetInteractable(true)
            LeaveGroupButton.SetInteractable(false)
        else
            -- If we are not the owner we can leave the group
            DeleteGroupButton.SetInteractable(false)
            LeaveGroupButton.SetInteractable(true)
        end
    end
    return ret
end

function ChatGroupClicked()
    local groups = {}
    for groupID, _ in pairs(Mod.PlayerGameData.ChatGroupMember) do
        groups[groupID] = Mod.PlayerGameData.ChatGroupMember[groupID]
        groups[groupID].GroupID = groupID
    end
    local options = Map(groups, ChatGroupButton)
    UI.PromptFromList("Select a chat group", options)
end

function GroupColorClicked()
    -- todo? Make a dialog to pick colors
    GroupColorButton.SetColor(RandomColor())
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

function TargetPlayerClicked()
    local options = Map(Filter(ClientGame.Game.Players, IsPotentialTarget),
                        PlayerButton)
    UI.PromptFromList(
        "Select the player you'd like to add or remove from a group", options)
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

-- Determins if the player is one we can interact with.
function IsPotentialTarget(player)
    if (ClientGame.Us.ID == player.ID) then return false end -- we can never add ourselves.

    if (player.State ~= WL.GamePlayerState.Playing) then return false end -- skip players not alive anymore, or that declined the game.

    if (ClientGame.Settings.SinglePlayer) then return true end -- in single player, allow proposing with everyone

    return not player.IsAI -- In multi-player, never allow adding an AI.
end
