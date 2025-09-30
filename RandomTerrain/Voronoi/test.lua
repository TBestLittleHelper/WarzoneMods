-- Debug toggle
local DRAW_SITES = false

-- Configuration
local WIDTH, HEIGHT = 1000, 1200
local NUM_SITES = 10
local CELL_SIZE = 50  -- Resolution control
local BONUS_LINK_SIZE = 16

math.randomseed(os.time())

-- Terrain types with RGB color codes
local terrainType = {
    Plains = {r = 200, g = 255, b = 200},
    Forest = {r = 34,  g = 139, b = 34},
    Hills = {r = 139, g = 69,  b = 19},
    Mountains = {r = 169, g = 169, b = 169},
    Desert = {r = 237, g = 201, b = 175},
    Water = {r = 28,  g = 107, b = 160}
}

-- Get random terrain type
local function randomTerrainType()
    local keys = {}
    for k in pairs(terrainType) do
        table.insert(keys, k)
    end
    local name = keys[math.random(#keys)]
    return terrainType[name]
end

-- Generate random sites with terrain colors
local function generate_sites(n)
    local sites = {}
    for i = 1, n do
        local terrain = randomTerrainType()
        sites[i] = {
            x = math.random() * WIDTH,
            y = math.random() * HEIGHT,
            r = terrain.r,
            g = terrain.g,
            b = terrain.b
        }
    end
    return sites
end

-- Find closest site to a point
local function closest_site(x, y, sites)
    local min_dist = math.huge
    local min_index = 1
    for i, site in ipairs(sites) do
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

-- Generate SVG Voronoi map
local function generate_svg(sites)
    local svg = {}
    table.insert(svg, string.format(
        '<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">',
        WIDTH, HEIGHT, WIDTH, HEIGHT
    ))

    -- Draw cells
    for y = 0, HEIGHT - 1, CELL_SIZE do
        for x = 0, WIDTH - 1, CELL_SIZE do
            local site = closest_site(x + CELL_SIZE / 2, y + CELL_SIZE / 2, sites)
            local color = string.format("rgb(%d,%d,%d)", site.r, site.g, site.b)
            table.insert(svg, string.format(
                '<rect x="%d" y="%d" width="%d" height="%d" fill="%s" stroke="black" stroke-width="0.5"/>',
                x, y, CELL_SIZE, CELL_SIZE, color
            ))
        end
    end

    -- Draw site centers (optional)
    if DRAW_SITES then
        for _, site in ipairs(sites) do
            table.insert(svg, string.format(
                '<circle cx="%.1f" cy="%.1f" r="4" fill="black" stroke="white" stroke-width="1"/>',
                site.x, site.y
            ))
        end
    end

    table.insert(svg, '</svg>')
    return table.concat(svg, "\n")
end

-- Write SVG to file
local function write_svg_file(filename, svg_data)
    local file = io.open(filename, "w")
    if not file then
        error("Failed to open file: " .. filename)
    end
    file:write(svg_data)
    file:close()
end

-- Main
local sites = generate_sites(NUM_SITES)
local svg_data = generate_svg(sites)
write_svg_file("voronoi_map.svg", svg_data)

print("SVG map generated: voronoi_map.svg")
