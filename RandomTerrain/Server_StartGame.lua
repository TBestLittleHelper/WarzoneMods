-- Resolution control
local WIDTH, HEIGHT = 3500, 2500 -- Max size of a map
local NUM_SITES = 500            -- Unused, we can experiment later
local CELL_SIZE = 100

-- TODO custom types
-- Terrain types
local terrainTypes = {
    Desert = { structureType = "Desert", weight = 0.2 },
    Grassland = { structureType = "Grassland", weight = 0.4 },
    Forest = { structureType = "Forest", weight = 0.3 },
    Mountain = { structureType = "Mountain", weight = 0.1 },
}

---@return string
local function randomTerrainType()
    local keys = {}
    for k in pairs(terrainTypes) do
        table.insert(keys, k)
    end
    local name = keys[math.random(#keys)]
    return terrainTypes[name].structureType
end
local function getWarzoneSites(territories)
    local sites = {}
    for _, territory in pairs(territories) do
        local terrainType = randomTerrainType();
        sites[territory.ID] = {
            ID = territory.ID,
            x = territory.MiddlePointX,
            y = territory.MiddlePointY,
            terrainType = terrainType,
            customStructureName = terrainTypes[terrainType].structureType,
        }
    end
    return sites
end

-- Find closest site to a point
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

local function placeStructures(sites, standing)
    for territoryID, territory in pairs(standing.Territories) do
        local site = sites[territoryID];

        local structure = {}
        local structureType = WL.StructureType.Custom(site.customStructureName);
        --territory.Structures = structure
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

    -- todo fix structure type terrainType
    ---@type table<integer, {x: number, y: number, terrainType:any, customStructureName: string}>
    local warzoneSites = getWarzoneSites(game.Map.Territories);
    print("Got warzoneSites")
    placeStructures(warzoneSites, standing);
    print("Placed structures")
end
