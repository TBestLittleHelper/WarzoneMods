require("Voronoi")

    --TODO config for Voronoi generation 

local config = {
        SVG_OUTPUT = false,
        RANDOM_SEED = 1000,
    }-- Resolution control

local WIDTH, HEIGHT = 3500, 2500 -- Max size of a map
local NUM_SITES = 500            -- Unused, we can experiment later
local CELL_SIZE = 100

---Places structures on the map based on the sites.
---@param standing GameStanding
local function placeStructures(TerritoryStructure, standing)
    for territoryID, territory in pairs(standing.Territories) do
        local site = TerritoryStructure[territoryID]
        print (site)
        print(site.customStructureName)
        if (site ~= nil) then
            local structure = {}
            local structureType = WL.StructureType.Custom(site.customStructureName)
            structure[structureType] = 1
            territory.Structures = structure
        else            
            print("No site found for territoryID: " .. territoryID)
        end       
    end
end

---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    local tickCount = WL.TickCount()
    print("TickCount: " .. tickCount)
    config.RANDOM_SEED = tickCount

    local TerritoryStructure = GenerateVoronoi(config, game)
    print("GeneratedVoronoi")
    placeStructures(TerritoryStructure, standing)
    print("Placed structures")
end
