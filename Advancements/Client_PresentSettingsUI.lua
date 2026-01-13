---@param rootParent RootParent
function Client_PresentSettingsUI(rootParent)
    ---@type UI UI
    UI = UI
    local vert = UI.CreateVerticalLayoutGroup(rootParent)
    local horz = UI.CreateHorizontalLayoutGroup(vert)
    UI.CreateLabel(horz).SetText("Advancements can't be customized. Maybe in the future.")
end
