-- Alias variables are typed here and defined in Enums.lua
---@alias AdvancementType "Economy" | "Culture" | "Armies"
---@alias AdvanceTurn "Start" | "Order" | "End"

---@alias UpgradeUID
---| 1   -- TradeStocks
---| 2   -- IndustrialFarms
---| 30  -- NationalSong
---| 60  -- Mercenaries
---| 61  -- SpyNetwork

-- Mod.Settings.Advancements data structure

-- Upgrade
---@class BaseUpgrade
---@field UID UpgradeUID
---@field Name string
---@field Description string
---@field Cost number
---@field AdvanceTurn AdvanceTurn

---@class EconomyUpgrade : BaseUpgrade
---@field IncomeThreshold number
---@field PointsPerIncome number

---@class CultureUpgrade : BaseUpgrade
---@field CitiesThreshold number
---@field PointsPerCity number

---@class ArmyUpgrade : BaseUpgrade
---@field ArmiesThreshold number?
---@field DeployBonus number?
---@field SpyReports number?

-- Category
---@class EconomyCategory
---@field Color string
---@field Enabled boolean
---@field PointsPerIncome number
---@field Upgrades EconomyUpgrade[]

---@class CultureCategory
---@field Color string
---@field Enabled boolean
---@field PointsPerCity number
---@field Upgrades CultureUpgrade[]

---@class ArmyCategory
---@field Color string
---@field Enabled boolean
---@field PointsPerArmy number
---@field Upgrades ArmyUpgrade[]

---@class Advancements
---@field Economy EconomyCategory
---@field Culture CultureCategory
---@field Armies ArmyCategory
