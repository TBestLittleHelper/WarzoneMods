require("ModSettings")
---@diagnostic disable-next-line: unknown-cast-variable
---@cast UI UI

---@type table<ModSettingsNames, {box: CheckBox, number: numberInput, max: integer}>  -- A table where keys are integers and values are PlayerID
---@diagnostic disable-next-line: undefined-global
SettingsTable = {} -- It is only accesible in Client_SaveConfigureUI

---Client_PresentConfigureUI hook
---@param rootParent RootParent
function Client_PresentConfigureUI(rootParent)

    local ModSettings = PresentConfigureModSettings()

    for modname, config in pairs(ModSettings) do
        local horizontalGroup = UI.CreateHorizontalLayoutGroup(rootParent);

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
    UI.CreateLabel(rootParent).SetText(
        "City Walls gives a defensive bonus to a territory with a city on it. The bonus stacks, for example if 1 city gives 50% extra defence. Then 2 cities gives 100%. Bomb card can reduce the number of cities on a territory by 2. A city of any size will protect the armies in that city from the bomb card!")
end
