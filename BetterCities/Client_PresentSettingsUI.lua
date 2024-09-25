require("ModSettings")

---@diagnostic disable-next-line: unknown-cast-variable
---@cast UI UI
---@diagnostic disable-next-line: unknown-cast-variable
---@cast Mod Mod  | ModClientHook  | ModSettings
---Client_PresentSettingsUI hook
---@param rootParent RootParent
function Client_PresentSettingsUI(rootParent)
    local settings = PresentSettingsModSettings()
    for modname, config in pairs(settings) do
        local horizontalGroup = UI.CreateHorizontalLayoutGroup(rootParent);
        if (type(config) == "boolean") then
            UI.CreateCheckBox(horizontalGroup).SetIsChecked(config)
                .SetInteractable(false).SetText(modname)
        else
            UI.CreateLabel(horizontalGroup).SetText(modname)
            UI.CreateNumberInputField(horizontalGroup).SetValue(config)
                .SetInteractable(false)
        end
    end

end
