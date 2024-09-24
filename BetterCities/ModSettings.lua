---@diagnostic disable-next-line: unknown-cast-variable
---@cast Mod Mod
function PresentConfigureModSettings()
    ---@type SettingsTable
    local settings = {
        cityWalls = {
            isBox = false,
            max = 100,
            initial = 20,
            text = "City Walls % bonus"
        },
        naturalCityGrowth = {isBox = true, text = "Natural city growth"},
        maxCitySize = {
            isBox = true,
            max = 10,
            initial = 2,
            text = "Max size of a city"
        },
        bombCardDamagesCities = {
            isBox = true,
            text = "Bomb card damages cities"
        },
        wastelandNeutralCities = {
            isBox = true,
            text = "Wasteland neutral cities"
        },
        extraArmiesInCity = {
            isBox = true,
            text = "Extra armies when deploying in a city"
        },
        deployOrdersOutsideCitySkipped = {
            isBox = true,
            text = "Deploy orders outside a city is skipped"
        },
        unfogCities = {
            isBox = true,
            text = "Cities are always visible to everyone"
        }
    }
    return settings
end

function GetAllModSettings() return Mod.Settings end

function GetModSettings(settingsName) return Mod.Settings[settingsName] end

function SetModSetting(settingsTable) Mod.Settings = settingsTable end
