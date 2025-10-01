-- Resolution control
local WIDTH, HEIGHT = 3500, 2500 -- Max size of a map
local NUM_SITES = 500            -- Unused, we can experiment later
local CELL_SIZE = 100

-- TODO custom types
-- Terrain types
local terrainTypes = {
    Desert = { structureType = "Arena" },
    Grassland = { structureType = "DigSite" },
    Forest = { structureType = "ArmyCache" },
    --Mountain = { "Mountain" },
    Water = { structureType = "MoneyCache" }
}

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
        local terrain = randomTerrainType();
        sites[territory.ID] = {
            ID = territory.ID,
            x = territory.MiddlePointX,
            y = territory.MiddlePointY,
            structureType = terrain,
        }
        -- print(sites[territory.ID].structureType)
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
    for _, territory in pairs(standing.Territories) do
        local structure = {}
        --  local structureType = WL.StructureType.Custom("Mountain");
        --territory.Structures = structure
        --  structure[structureType] = 1

        Cities = WL.StructureType.Custom("Mountain")
        structure[Cities] = 1
        territory.Structures = structure

        -- TODO Call WL.StructureType.Custom("MyStructure") to get a StructureType. You can pass this anyplace you would pass one of the above entries.
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
    print(WL.TickCount)
    -- math.randomseed(WL.TickCount())

    -- todo fix structure type typeing
    ---@type table<integer, {x: number, y: number, structureType: any}>
    local warzoneSites = getWarzoneSites(game.Map.Territories);
    print("Got warzoneSites")
    placeStructures(warzoneSites, standing);
    print("Placed structures")
end
