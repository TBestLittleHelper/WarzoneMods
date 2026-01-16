require("Enums")

---Client_PresentConfigureUI hook
---@param rootParent RootParent
function Client_PresentConfigureUI(rootParent)
    local settings = Mod.Settings
    local function safeEnabled(categoryName)
        local category = settings and settings.Advancements and settings.Advancements[categoryName]
        return category and category.Enabled ~= nil and category.Enabled or true
    end

    local savedEconomyEnabled = safeEnabled(AdvancementType.Economy)
    local savedCultureEnabled = safeEnabled(AdvancementType.Culture)
    local savedArmiesEnabled = safeEnabled(AdvancementType.Armies)


    local vert = UI.CreateVerticalLayoutGroup(rootParent)
    local horz = UI.CreateHorizontalLayoutGroup(vert)
    UI.CreateLabel(horz).SetText("Advancements can't be customized. Maybe in the future.")
    -- Must be globals for Save configure to work
    EconomyEnabledBox = UI.CreateCheckBox(vert).SetText("Enable Economy Advancements").SetIsChecked(
        savedEconomyEnabled)
    CultureEnabledBox = UI.CreateCheckBox(vert).SetText("Enable Culture Advancements").SetIsChecked(
        savedCultureEnabled)
    ArmiesEnabledBox = UI.CreateCheckBox(vert).SetText("Enable Armies Advancements").SetIsChecked(
        savedArmiesEnabled)
end
