require("ModSettings")

---@diagnostic disable-next-line: unknown-cast-variable
---@cast UI UI
---@diagnostic disable-next-line: unknown-cast-variable
---@cast Mod Mod  | ModClientHook  | ModSettings
---Client_PresentSettingsUI hook
---@param rootParent RootParent
function Client_PresentSettingsUI(rootParent)
    local settings = PresentSettingsModSettings()

    local vert = UI.CreateVerticalLayoutGroup(rootParent)
    local blue = "#0000FF"

    for _, config in pairs(settings) do
        local horizontalGroup = UI.CreateHorizontalLayoutGroup(vert);
        UI.CreateButton(horizontalGroup).SetFlexibleWidth(0.1).SetText("?")
            .SetColor(blue).SetOnClick(function()
            UI.Alert(config.longtext)
        end)

        if (config.isBox) then
            UI.CreateCheckBox(horizontalGroup).SetIsChecked(config.enabled)
                .SetInteractable(false).SetText(config.text)
        else
            UI.CreateLabel(horizontalGroup).SetText(config.text)
            UI.CreateNumberInputField(horizontalGroup).SetValue(config.value).SetSliderMinValue(0)
                .SetSliderMaxValue(config.max)
                .SetInteractable(false)
        end
    end
end
