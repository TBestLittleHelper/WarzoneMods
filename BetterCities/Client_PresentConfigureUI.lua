require("ModSettings")
---@diagnostic disable-next-line: unknown-cast-variable
---@cast UI UI
---@diagnostic disable-next-line: unknown-cast-variable
---@cast Mod ModSettings

---@type table<ModSettingsNames, {box: CheckBox} | {number: numberInput, max: integer}>  -- A table where keys are ModSettingsNames and values are either a checkbox or number with a max
---@diagnostic disable-next-line: undefined-global
SettingsTable = {} -- It is only accesible in Client_SaveConfigureUI

---Client_PresentConfigureUI hook
---@param rootParent RootParent
function Client_PresentConfigureUI(rootParent)
    local ModSettings = PresentConfigureModSettings()
    local vert = UI.CreateVerticalLayoutGroup(rootParent)

    for modname, config in pairs(ModSettings) do
        local horizontalGroup = UI.CreateHorizontalLayoutGroup(vert);
        UI.CreateButton(horizontalGroup).SetFlexibleWidth(0.1).SetText("?")
            .SetColor(UiHelpColor()).SetOnClick(function()
            UI.Alert(config.longtext)
        end)

        local templateConfig = Mod.Settings[modname]

        if (config.isBox) then
            local checked = (templateConfig == nil) and true or templateConfig
            local box = UI.CreateCheckBox(horizontalGroup).SetIsChecked(checked).SetText(config.text)
            SettingsTable[modname] = { box = box }
        else
            local initialNumber = (templateConfig ~= nil) and templateConfig or config.initial
            local number = UI.CreateNumberInputField(horizontalGroup)
                .SetSliderMaxValue(config.max)
                .SetValue(initialNumber)
            SettingsTable[modname] = { number = number, max = config.max }
            UI.CreateLabel(horizontalGroup).SetText(config.text)
        end
    end

    UI.CreateLabel(rootParent).SetText(
        "IMPORTANT: Turn off the option to build cities under army settings. Some mod functions only applies to cities the mod created.")
end
