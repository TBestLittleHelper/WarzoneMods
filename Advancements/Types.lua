---@alias AdvanceTurn "Start" | "Order" | "End"

---@class AdvancementUpgrade
---@field UID number
---@field Name string
---@field Description string
---@field Cost number
---@field AdvanceTurn AdvanceTurn
---@field IncomeThreshold number?      -- Economy-only
---@field PointsPerIncome number?      -- Economy-only
---@field CitiesThreshold number?      -- Culture-only
---@field PointsPerCity number?        -- Culture-only
---@field ArmiesThreshold number?      -- Army-only
---@field DeployBonus number?          -- Army-only
---@field SpyReports number?           -- Army-only

---@class AdvancementCategory
---@field Color string
---@field Enabled boolean
---@field PointsPerIncome number?      -- Economy base
---@field PointsPerCity number?        -- Culture base
---@field PointsPerArmy number?        -- Army base
---@field Upgrades AdvancementUpgrade[]

---@class Advancments
---@field Economy AdvancementCategory
---@field Culture AdvancementCategory
---@field Armies AdvancementCategory
