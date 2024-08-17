require("Utilities")
require("Client_ColorDialog")
require("Client_PlayerDialog")

local ClientGame;
local TargetGroupID;
local TargetPlayerID

-- local GroupColorButton;
local SelectedPlayerButton;
local GroupTextName;
local LeaveGroupButton;
local DeleteGroupButton;

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
    SelectedPlayerButton = UI.CreateButton(row1).SetText("Select player...")
                               .SetColor(RandomColor())
                               .SetOnClick(SelectePlayerClicked)

    local row11 = UI.CreateHorizontalLayoutGroup(vert)
    UI.CreateLabel(row11).SetText("Group name: ")
    GroupTextName = UI.CreateTextInputField(row11).SetCharacterLimit(25)
                        .SetPlaceholderText("Max 25 characters")
                        .SetPreferredWidth(200).SetFlexibleWidth(1)

    GroupColorButton = UI.CreateButton(row11).SetText("Color").SetColor(
                           RandomColor()).SetOnClick(GroupColorClicked)

    local row2 = UI.CreateHorizontalLayoutGroup(vert)
    if (next(playerGameData.ChatGroupMember) ~= nil) then
        UI.CreateButton(row2).SetText("Pick an existing group").SetOnClick(
            ChatGroupClicked)
    end
    -- Add a player to a group
    UI.CreateButton(row2).SetText("Add Player").SetColor("#00ff05").SetOnClick(
        function()
            if (TargetPlayerID == nil) then
                UI.Alert("Please select a player")
                return
            end
            if (GroupTextName.GetText() == nil or
                string.len(GroupTextName.GetText()) < 3) then
                UI.Alert("Please choose a group name with at least 3 characters") -- todo I don't like this wording
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
                SelectedPlayerButton.SetText("Select player...").SetColor(
                    RandomColor())
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
            SelectedPlayerButton.SetText("Select player...").SetColor(
                RandomColor())
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

        if (Mod.PlayerGameData.ChatGroupMember[TargetGroupID].OwnerID ~=
            ClientGame.Us.ID) then
            UI.Alert("You can only delete if you are the owner of a group")
            return
        end

        local payload = {}
        payload.Mod = "Chat"
        payload.Message = "DeleteGroup"
        payload.TargetGroupID = TargetGroupID

        -- Ask for confirmation from the player
        UI.PromptFromList("Are you sure you want to delete " ..
                              Mod.PlayerGameData.ChatGroupMember[TargetGroupID]
                                  .Name .. "?", {
            DeleteGroupConfirmed(ClientGame, payload), DeleteGroupDeclined()
        })
    end)
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
        GroupColorButton.SetOnClick(function()
            UI.Alert(
                "It's not possible to change the color of an existing group")
        end)
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

function GroupColorClicked() ClientGame.CreateDialog(ColorPickerDialog) end

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

function SelectePlayerClicked() ClientGame.CreateDialog(PlayerPickerDialog) end

-- local options = Map(Filter(ClientGame.Game.Players, IsPotentialTarget),
--                    PlayerButton)
-- UI.PromptFromList(
--    "Select the player you'd like to add or remove from a group", options)
-- end

function PlayerButton(player)
    local displayName = player.DisplayName(nil, false)
    return {
        text = displayName,
        selected = function()
            SelectedPlayerButton.SetText(displayName).SetColor(player.Color
                                                                   .HtmlColor)
            TargetPlayerID = player.ID
        end
    }
end
