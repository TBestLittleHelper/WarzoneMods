---@diagnostic disable-next-line: unknown-cast-variable
---@cast UI UI
---@type table<settingsName, {box: boxInput, number: numberInput}>  -- A table where keys are integers and values are PlayerID
---@diagnostic disable-next-line: undefined-global
SettingsTable = {}

---Client_PresentConfigureUI hook
---@param rootParent RootParent
function Client_PresentConfigureUI(rootParent)

    ---@param isBox boolean -- true if checkbox. Else NumberInput
    ---@param inputText string
    ---@param labelText string
    ---@param settingsName settingsName
    local function addInput(isBox, labelText, settingsName)
        local horizontalGroup = UI.CreateHorizontalLayoutGroup(rootParent);

        if (isBox) then
            local box = UI.CreateCheckBox(horizontalGroup)
            SettingsTable[settingsName] = {box = box}

        else
            local number = UI.CreateNumberInputField(horizontalGroup)
            SettingsTable[settingsName] = {number = number}
        end
        UI.CreateLabel(horizontalGroup).SetText(labelText)
    end

    addInput(false, "City Walls", "cityWalls")
    addInput(false, "Natural city growth", "naturalCityGrowth")
    addInput(true, "Max size of a city", "maxCitySize")
    addInput(false, "Bomb card damages cities", "bombCardDamagesCities")
    addInput(false, "Wastland neutral cities", "wastelandNeutralCities")
    addInput(false, "Extra armies when deploying in a city", "extraArmiesInCity")
    addInput(false, "Deploy orders outside a city is skipped",
             "deployOrdersOutsideCitySkipped")
    addInput(false, "Cities are always visible to everyone", "unfogCities")
end
