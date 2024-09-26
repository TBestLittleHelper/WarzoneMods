---@type SettingsTable
local Settings = {
    CityWalls = {
        isBox = false,
        max = 100,
        initial = 20,
        text = "City Walls % bonus",
        longtext =
        "City Walls gives a defensive bonus to a territory with a city on it. The bonus stacks, for example if 1 city gives 50% extra defence. Then 2 cities gives 100%."
    },
    NaturalCityGrowth = { isBox = true, text = "Natural city growth", longtext = "Every 5 turns, cities grown. Will respect max city size setting." },
    MaxCitySize = {
        isBox = true,
        max = 10,
        initial = 2,
        text = "Max size of a city",
        longtext = "Recomended. Prevents stacking cities for better gameplay."
    },
    BombCardDamagesCities = {
        isBox = true,
        text = "Bomb card damages cities",
        longtext =
        "Bomb card can reduce the number of cities on a territory by 1. A city of any size will protect the armies in that city from the bomb card!"
    },
    WastelandNeutralCities = { isBox = true, text = "Wasteland neutral cities" },
    ExtraArmiesInCity = {
        isBox = true,
        text = "Extra armies when deploying in a city",
        longtext = "Reduces the city size by 1, but double the armies deployed."
    },
    DeployOrdersOutsideCitySkipped = {
        isBox = true,
        text = "Deploy orders outside a city is skipped",
        longtext = "I don't know what text to put here."
    },
    UnfogCities = {
        isBox = true,
        text = "Cities are always visible to everyone",
        longtext = "This uses special units that's visible. One Army Must Stand Guard must be OFF for this to work!"
    },
    SettleCity = {
        isBox = true,
        text = "Players can settle a city from the mod menu.",
        longtext = "Maybe for a big hit to income? Like all the income for the next turn"
    }
}

---@diagnostic disable-next-line: unknown-cast-variable
---@cast Mod Mod  | ModSettings
function PresentConfigureModSettings() return Settings end

---Returns data the UI can use to show settings in game settings
---@return table<ModSettingsNames, { isBox: boolean, max: number, initial: number, text: string, longtext: string , enabled?:boolean, value?:integer}>
function PresentSettingsModSettings()
    local presentSetting = Settings

    for setting, defultConfig in pairs(presentSetting) do
        if (defultConfig.isBox) then
            presentSetting[setting].enabled = Mod.Settings[setting]
        else
            presentSetting[setting].value = Mod.Settings[setting]
        end
    end
    ---@cast presentSetting table<ModSettingsNames, { isBox: boolean, max: number, initial: number, text: string, longtext: string , enabled?:boolean, value?:integer}>
    return presentSetting
end
