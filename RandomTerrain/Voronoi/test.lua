-- Debug
local DRAW_SITES = false

-- Configuration
local WIDTH, HEIGHT = 1000, 1200
local NUM_SITES = 50
local CELL_SIZE = 30  -- Resolution control
local BONUS_LINK_SIZE = 16                 

math.randomseed(os.time())

-- Generate random sites
local function generate_sites(n)
    local sites = {}
    for i = 1, n do
        sites[i] = {
            x = math.random() * WIDTH,
            y = math.random() * HEIGHT,
            r = math.random(150, 255),
            g = math.random(150, 255),
            b = math.random(150, 255)
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
        local dist = dx*dx + dy*dy
        if dist < min_dist then
            min_dist = dist
            min_index = i
        end
    end
    return sites[min_index]
end

-- Generate Voronoi diagram as SVG rectangles (low resolution)
local function generate_svg(sites)
    local svg = {}
    table.insert(svg, string.format('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d">', WIDTH, HEIGHT))

    for y = 0, HEIGHT - 1, CELL_SIZE do
        for x = 0, WIDTH - 1, CELL_SIZE do
            local site = closest_site(x + CELL_SIZE/2, y + CELL_SIZE/2, sites)
            local color = string.format("rgb(%d,%d,%d)", site.r, site.g, site.b)
            table.insert(svg, string.format('<rect x="%d" y="%d" width="%d" height="%d" fill="%s" />',
                x, y, CELL_SIZE, CELL_SIZE, color))
        end
    end

    -- Draw site points
if (DRAW_SITES) then
    for _, site in ipairs(sites) do
        table.insert(svg, string.format(
            '<circle cx="%.1f" cy="%.1f" r="3" fill="black" />',
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
    file:write(svg_data)
    file:close()
end

-- Main
local sites = generate_sites(NUM_SITES)
local svg_data = generate_svg(sites)
write_svg_file("voronoi_map.svg", svg_data)

print("SVG map generated: voronoi_map.svg")
