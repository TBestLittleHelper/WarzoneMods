---Client_PresentConfigureUI hook
---@param rootParent RootParent
function Client_PresentConfigureUI(rootParent)
    local vert = UI.CreateVerticalLayoutGroup(rootParent)
    local horz = UI.CreateHorizontalLayoutGroup(vert)
    UI.CreateLabel(horz).SetText("Advancements can't be customized. Maybe in the future.")
end
