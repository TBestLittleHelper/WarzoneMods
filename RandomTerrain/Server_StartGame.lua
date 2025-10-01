require("Voronoi")

-- Resolution control
local WIDTH, HEIGHT = 3500, 2500 -- Max size of a map
local NUM_SITES = 500            -- Unused, we can experiment later
local CELL_SIZE = 100

---Places structures on the map based on the sites.
---@param standing GameStanding
local function placeStructures(TerritoryStructure, standing)
    for territoryID, territory in pairs(standing.Territories) do
        local site = sites[territoryID]
        local structure = {}
        local structureType = WL.StructureType.Custom(site.customStructureName)
        structure[structureType] = 1
        territory.Structures = structure
    end
end

---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    local tickCount = WL.TickCount()
    print("TickCount: " .. tickCount)
    -- math.randomseed(tickCount)

    --TODO config for Voronoi generation 
    local TerritoryStructure = GenerateVoronoi(nil, game)
    print("GeneratedVoronoi")
    placeStructures(TerritoryStructure, standing)
    print("Placed structures")
end
