---@diagnostic disable-next-line: unknown-cast-variable
---@cast Mod Mod
function PresentConfigureModSettings()
    ---@type SettingsTable
    local settings = {
        CityWalls = {
            isBox = false,
            max = 100,
            initial = 20,
            text = "City Walls % bonus"
        },
        NaturalCityGrowth = {isBox = true, text = "Natural city growth"},
        MaxCitySize = {
            isBox = true,
            max = 10,
            initial = 2,
            text = "Max size of a city"
        },
        BombCardDamagesCities = {
            isBox = true,
            text = "Bomb card damages cities"
        },
        WastelandNeutralCities = {
            isBox = true,
            text = "Wasteland neutral cities"
        },
        ExtraArmiesInCity = {
            isBox = true,
            text = "Extra armies when deploying in a city"
        },
        DeployOrdersOutsideCitySkipped = {
            isBox = true,
            text = "Deploy orders outside a city is skipped"
        },
        UnfogCities = {
            isBox = true,
            text = "Cities are always visible to everyone"
        }
    }
    return settings
end

function GetAllModSettings() return Mod.Settings end

function GetModSettings(settingsName) return Mod.Settings[settingsName] end

function SetModSetting(settingsTable) Mod.Settings = settingsTable end
