-- Add scrolling, space finishes map before starting another.

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

	xCenter, yCenter, scrollSpeed = 0, 0, 250
end

function love.draw()
	local sx, sy = scrollOffset()
	love.graphics.push();  love.graphics.translate(sx, sy)
	drawMap(map)
	love.graphics.pop()
end

function scrollOffset()
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	return width/2 - xCenter,  height/2 - yCenter
end

function love.keypressed(key)
	if key == 'space' then
		if isComplete(map) then
			resetMap(map)
		else
			local oldStep = step;  step = 0
			love.update(0)
			step = oldStep
		end
	end
end

function love.update(dt)
	local dx, dy = getArrowKeys()
	xCenter = xCenter + dx * scrollSpeed * dt
	yCenter = yCenter + dy * scrollSpeed * dt

	if isComplete(map) then unsimulated = 0
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
		x=0, y=0, dir=0,
		dirChances = normalizedChances(dirChances),
		rooms = rooms,
		roomChances = normalizedChances(roomChances)
	}
end

function clearMap(map)
	map.n = 0
	map.floorTiles = {}
	map.x = 0;  map.y = 0;  map.dir = 0;
end

function isComplete(map)  return map.n >= map.max  end

function resetMap(map)
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
	local canPlace = not isComplete(map)
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



function getArrowKeys()
	-- arrow keys, qwerty, azerty, dvorak
	local u = boolToNum(love.keyboard.isDown('up',    'w', 'z', ','))
	local l = boolToNum(love.keyboard.isDown('left',  'a', 'q'))
	local d = boolToNum(love.keyboard.isDown('down',  's',      'o'))
	local r = boolToNum(love.keyboard.isDown('right', 'd',      'e'))
	return r - l, d - u
end

function boolToNum(b) return b and 1 or 0 end
