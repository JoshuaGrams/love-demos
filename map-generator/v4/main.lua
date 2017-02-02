function love.load()
	tSz = 16

	step = 0.01
	unsimulated = 0

	map = newMap(150)
	math.randomseed(seedFromClock())

	love.graphics.setBackgroundColor(36, 33, 18)
end

function love.draw()
	drawMap(map)
end

function love.keypressed(key)
	if key == 'space' then resetMap(map) end
end

function love.update(dt)
	unsimulated = unsimulated + dt
	while unsimulated >= step and placeFloor(map) do
		unsimulated = unsimulated - step
		moveRandomly(map)
	end
end

function drawMap(map)
	love.graphics.setColor(30, 140, 22)
	for k,v in pairs(map.floorTiles) do
		drawFloor(v[1], v[2])
	end
	love.graphics.setColor(30, 220, 40)
	drawFloor(map.x, map.y)
end

function drawFloor(x, y)
	love.graphics.rectangle("fill", x*tSz, y*tSz, tSz, tSz)
end

function newMap(floorCount)
	return {
		n=0, max=floorCount,
		floorTiles={},
		-- dir is quarter-turns clockwise from right
		x=25, y=18, dir=0,
		exits = { {1,0}, {0,1}, {-1,0}, {0,-1} }
	}
end

function clearMap(map)
	map.n = 0
	map.floorTiles = {}
	map.x = 25;  map.y = 18;  map.dir = 0;
end

function resetMap(map)
	clearMap(map)
	math.randomseed(seedFromClock())
end

function seedFromClock()
	local seed = os.time() + math.floor(1000 * os.clock())
	seed = seed * seed % 1000000
	seed = seed * seed % 1000000
	print(seed)
	return seed
end

function generateMap(map, seed)
	math.randomseed(seed)
	while placeFloor(map) do
		moveRandomly(map)
	end
	return map
end

function placeFloor(map)
	local canPlace = map.n < map.max
	if canPlace then
		local key = tostring(map.x) .. ',' .. tostring(map.y)
		if map.floorTiles[key] == nil then
			map.floorTiles[key] = {map.x, map.y}
			map.n = map.n + 1
		end
	end
	return canPlace
end

function moveRandomly(map)
	map.dir = (map.dir + math.random(0, 3)) % 4
	local e = map.exits[map.dir+1]
	map.x = map.x + e[1]
	map.y = map.y + e[2]
end
