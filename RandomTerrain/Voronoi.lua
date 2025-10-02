--- Generate a Voronoi map with random terrain types. Output as SVG or as points for a WZ map.

local SVG_OUTPUT = true -- Set to false for WZ map points

-- Default configuration
local WIDTH, HEIGHT = 3500, 2500
local NUM_SITES = 100
local CELL_SIZE = 60 -- Resolution control

-- Terrain types with color codes (for svg output)
local terrainType = {
    { structureType = "Desert",    weight = 0.2, color = "#EDC9AF" },
    { structureType = "Grassland", weight = 0.4, color = "#C8FFC8" },
    { structureType = "Forest",    weight = 0.3, color = "#044e04ff" },
    { structureType = "Mountain",  weight = 0.1, color = "#A9A9A9" }
}

-- Terrain adjacency influence rules
local terrainInfluenceRules = {
    ["Forest"] = { preferred = { "Grassland" }, avoid = { "Desert" } },
    ["Grassland"] = { preferred = { "Forest", "Desert" }, avoid = { "Mountain" } },
    ["Desert"] = { preferred = { "Grassland" }, avoid = { "Forest" } },
    ["Mountain"] = { preferred = { "Forest" }, avoid = {} },
}


local function setConfigOpt(config)
    print("Setting config options")
    -- print k and v for each key value pair in config
    for k, v in pairs(config) do
        print(k, v)
    end
    if config.WIDTH then WIDTH = config.WIDTH end
    if config.HEIGHT then HEIGHT = config.HEIGHT end
    if config.NUM_SITES then NUM_SITES = config.NUM_SITES end
    if config.CELL_SIZE then CELL_SIZE = config.CELL_SIZE end
    if config.SVG_OUTPUT ~= nil then SVG_OUTPUT = config.SVG_OUTPUT end
    --    if config.RANDOM_SEED then math.randomseed(config.RANDOM_SEED) else math.randomseed(os.time()) end
    if config.TERRAIN_TYPE then terrainType = config.TERRAIN_TYPE end
end


-- Weighted random terrain picker
local function pick_terrain()
    local r = math.random()
    local accumulator = 0
    for _, terrain in ipairs(terrainType) do
        accumulator = accumulator + terrain.weight
        if r <= accumulator then return terrain end
    end
    return terrainType[#terrainType]
end

-- Generate random sites
local function generate_sites(n)
    local sites = {}
    for i = 1, n do
        sites[i] = {
            x = math.random() * WIDTH,
            y = math.random() * HEIGHT,
            terrain = pick_terrain()
        }
    end
    return sites
end

---@class VoronoiSite
---@field x number
---@field y number
---@field terrain table

---Find the nearest site for a given cell
---@param sites VoronoiSite[]
---@param x number
---@param y number
---@return VoronoiSite
local function find_nearest_site(sites, x, y)
    local nearest = sites[1]
    local min_dist2 = math.huge
    for _, site in ipairs(sites) do
        local dx = x - site.x
        local dy = y - site.y
        local dist2 = dx * dx + dy * dy
        if dist2 < min_dist2 then
            min_dist2 = dist2
            nearest = site
        end
    end
    return nearest
end


-- Map generation
local function process_cells(sites, cell_handler_callback)
    for y = 0, HEIGHT, CELL_SIZE do
        for x = 0, WIDTH, CELL_SIZE do
            local site = find_nearest_site(sites, x, y)
            cell_handler_callback(x, y, site)
        end
    end
end

-- SVG generation
local function generate_svg(sites)
    local svg = {}
    table.insert(svg, string.format('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d">', WIDTH, HEIGHT))

    -- Add Voronoi cells
    process_cells(sites, function(x, y, site)
        table.insert(svg, string.format(
            '<rect x="%d" y="%d" width="%d" height="%d" fill="%s"/>',
            x, y, CELL_SIZE, CELL_SIZE, site.terrain.color
        ))
    end)

    -- Add site markers
    for _, site in ipairs(sites) do
        table.insert(svg, string.format(
            '<circle cx="%.1f" cy="%.1f" r="5" fill="black"/>',
            site.x, site.y
        ))
    end

    table.insert(svg, '</svg>')

    -- NOTE! The following file operations are disabled in Warzone environment. Uncomment if running locally. When submitting to Warzone, ensure these lines remain commented out.
    --    local output = table.concat(svg, "\n")
    --    local file = io.open("voronoi_map.svg", "w")
    --    file:write(output)
    --    file:close()
    print("SVG map generated: voronoi_map.svg")
end


-- Warzone Structure generation
local function generate_wz_points(sites, territories)
    local territoryStructures = {}

    for _, territory in pairs(territories) do
        local nearestSite = find_nearest_site(sites, territory.MiddlePointX, territory.MiddlePointY)

        territoryStructures[territory.ID] = {
            customStructureName = nearestSite.terrain.structureType
        }
    end

    return territoryStructures
end

---@diagnostic disable-next-line: unknown-cast-variable
---@cast WL WL
---@param configOpt table|nil
---@param game GameServerHook
function GenerateVoronoi(configOpt, game)
    if configOpt then setConfigOpt(configOpt) end
    local sites = generate_sites(NUM_SITES)
    if SVG_OUTPUT then
        generate_svg(sites)
    else
        local TerritoryStructures = generate_wz_points(sites, game.Map.Territories)
        return TerritoryStructures;
    end
end

--GenerateVoronoi()
