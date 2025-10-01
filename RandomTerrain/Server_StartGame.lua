-- Resolution control
local WIDTH, HEIGHT = 3500, 2500 -- Max size of a map
local NUM_SITES = 500            -- Unused, we can experiment later
local CELL_SIZE = 100

---@class TerrainType
---@field structureType string
---@field weight number

---@type TerrainType[]
local terrainTypes = {
    { structureType = "Desert", weight = 0.2 },
    { structureType = "Grassland", weight = 0.4 },
    { structureType = "Forest", weight = 0.3 },
    { structureType = "Mountain", weight = 0.1 },
}

---Calculates the total weight of all terrain types.
---@return number
local function calculateTotalWeight()
    local total = 0
    for _, t in ipairs(terrainTypes) do
        total = total + t.weight
    end
    return total
end

--- Selects a random terrain type based on weighted probabilities.
---@param totalWeight number The sum of all terrain weights.
---@return TerrainType The randomly selected terrain type.
local function randomTerrainType(totalWeight)
    local rnd = math.random() * totalWeight
    for _, terrain in ipairs(terrainTypes) do
        rnd = rnd - terrain.weight
        if rnd <= 0 then
            return terrain
        end
    end
    print("randomTerrainType failed ", rnd)
    return terrainTypes[#terrainTypes]
end

---@class WarzoneSite
---@field ID integer
---@field x number
---@field y number
---@field terrainType string
---@field customStructureName string

---Assigns a random terrain type to each territory and returns a table of sites.
---@param territories table<integer, Territory>
---@return table<integer, WarzoneSite>
local function getWarzoneSites(territories)
    local totalWeight = calculateTotalWeight()
    print("totalWeight: " .. totalWeight)

    ---@type table<integer, WarzoneSite>
    local sites = {}
    for _, territory in pairs(territories) do
        local terrainType = randomTerrainType(totalWeight)
        print("Assigned terrainType: " .. terrainType.structureType .. " to territory ID: " .. territory.ID)
        sites[territory.ID] = {
            ID = territory.ID,
            x = territory.MiddlePointX,
            y = territory.MiddlePointY,
            terrainType = terrainType.structureType,
            customStructureName = terrainType.structureType,
        }
    end
    return sites
end

---Finds the closest site to a given point.
---@param x number
---@param y number
---@param sites table<integer, WarzoneSite>
---@return WarzoneSite
local function closest_site(x, y, sites)
    local min_dist = math.huge
    local min_index = 1
    for i, site in pairs(sites) do
        local dx = x - site.x
        local dy = y - site.y
        local dist = dx * dx + dy * dy
        if dist < min_dist then
            min_dist = dist
            min_index = i
        end
    end
    return sites[min_index]
end

---Places structures on the map based on the sites.
---@param sites table<integer, WarzoneSite>
---@param standing GameStanding
local function placeStructures(sites, standing)
    for territoryID, territory in pairs(standing.Territories) do
        local site = sites[territoryID]

        local structure = {}
        local structureType = WL.StructureType.Custom(site.customStructureName)
        structure[structureType] = 1
        territory.Structures = structure
    end
end

---@diagnostic disable-next-line: unknown-cast-variable
---@cast Mod ModServerHook  | ModSettings
---@diagnostic disable-next-line: unknown-cast-variable
---@cast WL WL

---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    local tickCount = WL.TickCount()
    print("TickCount: " .. tickCount)
    -- math.randomseed(WL.TickCount())

    ---@type table<integer, WarzoneSite>
    local warzoneSites = getWarzoneSites(game.Map.Territories)
    print("Got warzoneSites")
    placeStructures(warzoneSites, standing)
    print("Placed structures")
end
