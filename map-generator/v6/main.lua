-- Randomly place different rooms.

function love.load()
	tSz = 16

	step = 0.01
	unsimulated = 0

	rooms = {
		{
			chance = 10,
			tiles = { {0,0} },
			exits = { {1,0}, {0,1}, {-1,0}, {0,-1} }
		},
		{  -- 2x2 room
			chance = 3,
			tiles = { {0,0}, {1,0}, {0,-1}, {1,-1} },
			exits = { {2,0}, {0,1}, {-1,0}, {0,-2} }
		},
		{  -- 3x3 room
			chance = 1,
			tiles = {
				{0,-1}, {0,0}, {0,1},
				{1,-1}, {1,0}, {1,1},
				{2,-1}, {2,0}, {2,1}
			},
			exits = { {3,0}, {1,2}, {-1,0}, {1,-2} }
		}
	}

	map = newMap(150, {3, 1, 0, 1}, rooms)
	math.randomseed(generateSeedFromClock())

	love.graphics.setBackgroundColor(36, 33, 18)
end

function love.draw()
	drawMap(map)
end

function love.keypressed(key)
	if key == 'space' then reseedMap(map) end
end

function love.update(dt)
	if map.n >= map.max then unsimulated = 0
	else unsimulated = unsimulated + dt end
	while unsimulated >= step and placeRandomRoom(map) do
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

function newMap(floorCount, dirChances, rooms)
	local roomChances = {}
	for i=1,#rooms do roomChances[i] = rooms[i].chance end
	return {
		n=0, max=floorCount,
		floorTiles={},
		-- dir is quarter-turns clockwise from right
		x=25, y=18, dir=0,
		dirChances = normalizedChances(dirChances),
		rooms = rooms,
		roomChances = normalizedChances(roomChances)
	}
end

function clearMap(map)
	map.n = 0
	map.floorTiles = {}
	map.x = 25;  map.y = 18;  map.dir = 0;
end

function reseedMap(map)
	clearMap(map)
	math.randomseed(generateSeedFromClock())
end

function generateSeedFromClock()
	local seed = os.time() + math.floor(1000 * os.clock())
	seed = seed * seed % 1000000
	seed = seed * seed % 1000000
	print(seed)
	return seed
end

function generateMap(map, seed)
	math.randomseed(seed)
	while placeRandomRoom(map) do
		moveRandomly(map)
	end
	return map
end

function placeRandomRoom(map)
	local canPlace = map.n < map.max
	if canPlace then
		addRoom(map, map.rooms[randomChoice(map.roomChances)])
	end
	return canPlace
end

function addRoom(map, room)
	map.exits = room.exits
	for i=1,#room.tiles do
		local t = room.tiles[i]
		addTile(map, map.x + t[1], map.y + t[2])
	end
end

function addTile(map, x, y)
	local key = tostring(x) .. ',' .. tostring(y)
	if map.floorTiles[key] == nil then
		map.floorTiles[key] = {x, y}
		map.n = map.n + 1
	end
end

function moveRandomly(map)
	local turn = randomChoice(map.dirChances) - 1
	map.dir = (map.dir + turn) % 4
	local e = map.exits[map.dir+1]
	map.x = map.x + e[1]
	map.y = map.y + e[2]
end

function randomChoice(chances)
	local rnd, cur = math.random(), 0
	for i=1,#chances do
		cur = cur + chances[i]
		if rnd < cur then return i end
	end
	return #chances
end

function normalizedChances(chances)
	local sum, c = 0, {}
	for i=1,#chances do sum = sum + chances[i] end
	local scale = 1 / sum
	for i=1,#chances do c[i] = chances[i] * scale end
	return c
end
