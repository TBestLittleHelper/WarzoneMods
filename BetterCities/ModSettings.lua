---@type SettingsTable
local Settings = {
    CityWalls = {
        isBox = false,
        max = 100,
        initial = 20,
        text = "City Walls % bonus",
        longtext = "City Walls gives a defensive bonus to a territory with a city on it. The bonus stacks, for example if 1 city gives 50% extra defence. Then 2 cities gives 100%. Bomb card can reduce the number of cities on a territory by 2. A city of any size will protect the armies in that city from the bomb card!"
    },
    NaturalCityGrowth = {isBox = true, text = "Natural city growth"},
    MaxCitySize = {
        isBox = true,
        max = 10,
        initial = 2,
        text = "Max size of a city"
    },
    BombCardDamagesCities = {isBox = true, text = "Bomb card damages cities"},
    WastelandNeutralCities = {isBox = true, text = "Wasteland neutral cities"},
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
        text = "Cities are always visible to everyone",
        longtext = "This uses special units that's visible. One Army Must Stand Guard must be OFF for this to work!"
    },
    SettleCity = {
        isBox = true,
        text = "Players can settle a city from the mod menu."
    }
}

---@diagnostic disable-next-line: unknown-cast-variable
---@cast Mod Mod  | ModSettings
function PresentConfigureModSettings() return Settings end

function PresentSettingsModSettings()
    local presentSetting = Mod.Settings

    ---Lookup the long text
    ---@param settingsName ModSettingsNames
    ---@return string
    local function getLongText(settingsName)
        return Settings[settingsName].longtext
    end
    for settingsName, _ in pairs(presentSetting) do
        presentSetting[settingsName].longtext = getLongText(settingsName)
    end

    return presentSetting
end
