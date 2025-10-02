require("Voronoi")

--TODO config for Voronoi generation

local config = {
    SVG_OUTPUT = false,
    RANDOM_SEED = 1000,
    WIDTH = 4500,
    HEIGHT = 2500,
    NUM_SITES = 500,
    CELL_SIZE = 100,
}

---Places structures on the map based on the sites.
---@param standing GameStanding
local function placeStructures(TerritoryStructure, standing, game)
    for territoryID, territory in pairs(standing.Territories) do
        local site = TerritoryStructure[territoryID]
        print(site)
        if (site ~= nil) then
            print(site.customStructureName)
            local structure = {}
            local structureType = WL.StructureType.Custom(site.customStructureName)
            structure[structureType] = 1
            territory.Structures = structure
        else
            print("No site found for territoryID: " ..
                territoryID ..
                " x,y :  " ..
                game.Map.Territories[territoryID].MiddlePointX .. "," .. game.Map.Territories[territoryID].MiddlePointY)
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
    placeStructures(TerritoryStructure, standing, game)
    print("Placed structures")
end
