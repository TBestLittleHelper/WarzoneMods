---Client_PresentConfigureUI hook
---@param rootParent RootParent
function Client_PresentConfigureUI(rootParent)

    ---@type settingsTable
    local settingsTable;

    ---@param boxText string
    ---@param labelText string
    ---@param settingsName settingsName
    local function addCheckbox(boxText, labelText, settingsName)
        local box = UI.CreateCheckBox(rootParent).SetText(boxText)
        local label = UI.CreateLabel(rootParent).SetText(labelText)
        table.insert(settingsTable, {settingsName = box})
    end

    addCheckbox("City Walls", "City Walls", "cityWalls")
    addCheckbox("Natural city growth", "Natural city growth",
                "naturalCityGrowth")
    addCheckbox("Bomb card damages cities", "Bomb card damages cities",
                "bombCardDamagesCities")
    addCheckbox("Wastland neutral cities", "Wastland neutral cities",
                "wastelandNeutralCities")
    addCheckbox("Extra armies when deploying in a city",
                "Extra armies when deploying in a city", "extraArmiesInCity")
    addCheckbox("Deploy orders outside a city is skipped",
                "Deploy orders outside a city is skipped",
                "deployOrdersOutsideCitySkipped")

end
