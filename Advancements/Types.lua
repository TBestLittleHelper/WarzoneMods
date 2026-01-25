-- Alias variables are typed here and defined in Enums.lua
---@alias AdvancementType "Economy" | "Culture" | "Armies"
---@alias AdvanceTurn "Start" | "Order" | "End"

---@alias EconomyUID
---| 1   -- Trade Stocks
---| 2   -- Industrial Farms
---| 3   -- Universal Basic Income
---| 4   -- Welfare Fund

---@alias CultureUID
---| 30  -- National Song Competition
---| 31  -- Urban Life
---| 32  -- Public Education
---| 33  -- Sportswashing

---@alias ArmyUID
---| 60  -- Mercenaries
---| 61  -- Spy Network in Cities
---| 62  -- Combat Experience
---| 63  -- Infiltrate Big Armies

---@alias UpgradeUID EconomyUID | CultureUID | ArmyUID

-- Mod.Settings.Advancements data structure

-- Upgrade
---@class BaseUpgrade
---@field UID UpgradeUID
---@field Name string
---@field Description string
---@field Cost number
---@field AdvanceTurn AdvanceTurn

---@class EconomyUpgrade : BaseUpgrade
---@field UID EconomyUID
---@field IncomeThreshold number?
---@field PointsPerIncome number?
---@field BasicIncome number?

---@class CultureUpgrade : BaseUpgrade
---@field UID CultureUID
---@field CitiesThreshold number?
---@field PointsPerCity number?
---@field IncomePerCity number?

---@class ArmyUpgrade : BaseUpgrade
---@field UID ArmyUID
---@field ArmiesThreshold number?
---@field DeployBonus number?
---@field SpyReports number?
---@field PointsPerWinningAttack number?
---@field BigArmySize number?

-- Category
---@class EconomyCategory
---@field Color string
---@field Enabled boolean
---@field PointsPerIncome number
---@field Upgrades table<EconomyUID, EconomyUpgrade>

---@class CultureCategory
---@field Color string
---@field Enabled boolean
---@field PointsPerCity number
---@field Upgrades table<CultureUID, CultureUpgrade>

---@class ArmiesCategory
---@field Color string
---@field Enabled boolean
---@field PointsPerArmy number
---@field Upgrades table<ArmyUID, ArmyUpgrade>

---@class Advancements
---@field Economy EconomyCategory
---@field Culture CultureCategory
---@field Armies ArmiesCategory
