---@diagnostic disable-next-line: unknown-cast-variable
---@cast UI UI
---@type table<settingsName, {box: CheckBox, number: numberInput}>  -- A table where keys are integers and values are PlayerID
---@diagnostic disable-next-line: undefined-global
SettingsTable = {} -- It is only accesible in Client_SaveCOnfigureUI

---Client_PresentConfigureUI hook
---@param rootParent RootParent
function Client_PresentConfigureUI(rootParent)

    ---@param uiConfig addUiInput
    ---@param labelText string
    ---@param settingsName ModSettingsNames
    local function addInput(uiConfig, labelText, settingsName)
        local horizontalGroup = UI.CreateHorizontalLayoutGroup(rootParent);

        if (uiConfig.isBox) then
            local box = UI.CreateCheckBox(horizontalGroup)
            box.SetText(labelText)
            SettingsTable[settingsName] = {box = box}
        else
            local number = UI.CreateNumberInputField(horizontalGroup)
            number.SetSliderMaxValue(uiConfig.max).SetValue(uiConfig.initial)
            SettingsTable[settingsName] = {number = number}
            UI.CreateLabel(horizontalGroup).SetText(labelText)
        end
    end

    addInput({isBox = false, max = 100, initial = 20}, "City Walls % bonus",
             "cityWalls")
    addInput({isBox = true}, "Natural city growth", "naturalCityGrowth")
    addInput({isBox = true, max = 10, initial = 2}, "Max size of a city",
             "maxCitySize")
    addInput({isBox = true}, "Bomb card damages cities", "bombCardDamagesCities")
    addInput({isBox = true}, "Wastland neutral cities", "wastelandNeutralCities")
    addInput({isBox = true}, "Extra armies when deploying in a city",
             "extraArmiesInCity")
    addInput({isBox = true}, "Deploy orders outside a city is skipped",
             "deployOrdersOutsideCitySkipped")
    addInput({isBox = true}, "Cities are always visible to everyone",
             "unfogCities")

    UI.CreateLabel(rootParent).SetText(
        "IMPORTANT: When using this mod it's strongely recomended that you make the price to build cities extremely exspensiv, to the point where players can't build cities using gold. Or just turn of the option under army settings.")
    UI.CreateLabel(rootParent).SetText(
        "City Walls gives a defensive bonus to a territory with a city on it. The bonus stacks, for example if 1 city gives 50% extra defence. Then 2 cities gives 100%. Bomb card can reduce the number of cities on a territory by 2. A city of any size will protect the armies in that city from the bomb card!")
end
