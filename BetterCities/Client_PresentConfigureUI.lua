require("ModSettings")
---@diagnostic disable-next-line: unknown-cast-variable
---@cast UI UI

---@type table<ModSettingsNames, {box: CheckBox} | {number: numberInput, max: integer}>  -- A table where keys are ModSettingsNames and values are either a checkbox or number with a max
---@diagnostic disable-next-line: undefined-global
SettingsTable = {} -- It is only accesible in Client_SaveConfigureUI

---Client_PresentConfigureUI hook
---@param rootParent RootParent
function Client_PresentConfigureUI(rootParent)

    local ModSettings = PresentConfigureModSettings()
    local blue = "#0000FF"

    for modname, config in pairs(ModSettings) do
        local horizontalGroup = UI.CreateHorizontalLayoutGroup(rootParent);
        UI.CreateButton(horizontalGroup).SetText("?").SetColor(blue).SetOnClick(
            function() UI.Alert("TODO!") end)

        if (config.isBox) then
            local box = UI.CreateCheckBox(horizontalGroup)
            box.SetText(config.text)
            SettingsTable[modname] = {box = box}
        else
            local number = UI.CreateNumberInputField(horizontalGroup)
            number.SetSliderMaxValue(config.max).SetValue(config.initial)
            SettingsTable[modname] = {number = number, max = config.max}
            UI.CreateLabel(horizontalGroup).SetText(config.text)
        end
    end

    UI.CreateLabel(rootParent).SetText(
        "IMPORTANT: When using this mod it's strongely recomended that you make the price to build cities extremely exspensiv, to the point where players can't build cities using gold. Or just turn of the option under army settings.")
end
