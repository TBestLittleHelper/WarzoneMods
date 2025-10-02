-- Constants
local WIDTH, HEIGHT = 3500, 2500
local NUM_SITES = 500 -- Not used in current implementation
local CELL_SIZE = 100

-- Terrain type definitions
local terrainTypes = {
	Desert = { name = "Desert", weight = 0.2 },
	Grassland = { name = "Grassland", weight = 0.4 },
	Forest = { name = "Forest", weight = 0.3 },
	Mountain = { name = "Mountain", weight = 0.1 },
}

-- Pick terrain based on weights
local function weightedRandomTerrain()
	local totalWeight = 0
	for _, t in pairs(terrainTypes) do
		totalWeight = totalWeight + t.weight
	end

	local rnd = math.random() * totalWeight
	for _, t in pairs(terrainTypes) do
		rnd = rnd - t.weight
		if rnd <= 0 then
			return t.name
		end
	end
	return "Grassland" -- fallback
end

-- Get distance squared between two points
local function dist2(x1, y1, x2, y2)
	local dx = x1 - x2
	local dy = y1 - y2
	return dx * dx + dy * dy
end

-- Build a mapping of territories with assigned terrain
local function assignTerrainToSites(territories)
	local sites = {}

	-- First pass: assign terrain based on weighted random
	for _, territory in pairs(territories) do
		local terrain = weightedRandomTerrain()
		sites[territory.ID] = {
			ID = territory.ID,
			x = territory.MiddlePointX,
			y = territory.MiddlePointY,
			terrainType = terrain,
			customStructureName = terrain,
			neighbors = {}, -- fill later
		}
	end

	-- Build neighbor map (rough)
	local siteList = {}
	for _, s in pairs(sites) do table.insert(siteList, s) end
	for _, site in ipairs(siteList) do
		local nearest = {}
		for _, other in ipairs(siteList) do
			if site.ID ~= other.ID then
				local d = dist2(site.x, site.y, other.x, other.y)
				table.insert(nearest, { id = other.ID, dist = d })
			end
		end
		table.sort(nearest, function(a, b) return a.dist < b.dist end)
		for i = 1, math.min(6, #nearest) do
			table.insert(site.neighbors, nearest[i].id)
		end
	end

	-- Second pass: adjust terrain for grassland preference near forest
	for _, site in pairs(sites) do
		if site.terrainType == "Forest" then
			for _, neighborID in ipairs(site.neighbors) do
				local neighbor = sites[neighborID]
				if neighbor.terrainType == "Desert" and math.random() < 0.5 then
					neighbor.terrainType = "Grassland"
					neighbor.customStructureName = "Grassland"
				end
			end
		end
	end

	return sites
end

-- Place structure in each territory
local function placeStructures(sites, standing)
	for territoryID, territory in pairs(standing.Territories) do
		local site = sites[territoryID]
		local structure = {}
		local structureType = WL.StructureType.Custom(site.customStructureName)
		structure[structureType] = 1
		territory.Structures = structure
	end
end

-- Entry point
function Server_StartGame(game, standing)
	local tickCount = WL.TickCount()
	print("TickCount: " .. tickCount)
	math.randomseed(tickCount)

	local warzoneSites = assignTerrainToSites(game.Map.Territories)
	print("Assigned terrain to sites")
	placeStructures(warzoneSites, standing)
	print("Placed structures")
end
