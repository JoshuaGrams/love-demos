-- Branching (multiple walkers).

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

	map = newMap(150, {3, 1, 0, 1}, 0.02, rooms)
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
			reseedMap(map)
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

	while unsimulated >= step and not isComplete(map) do
		unsimulated = unsimulated - step
		generationStep(map)
	end
end

function drawMap(map)
	love.graphics.setColor(30, 140, 22)
	for k,v in pairs(map.floorTiles) do
		drawFloor(v[1], v[2])
	end
	love.graphics.setColor(30, 220, 40)
	for w=1,#map.walkers do
		local w = map.walkers[w]
		drawFloor(w.x, w.y)
	end
end

function drawFloor(x, y)
	love.graphics.rectangle("fill", x*tSz, y*tSz, tSz, tSz)
end

function newMap(floorCount, dirChances, branchChance, rooms)
	local roomChances = {}
	for i=1,#rooms do roomChances[i] = rooms[i].chance end
	local map = {
		max=floorCount,
		dirChances = normalizedChances(dirChances),
		rooms = rooms,
		roomChances = normalizedChances(roomChances),
		branchChancePerStep = branchChance
	}
	clearMap(map)
	return map
end

function clearMap(map)
	map.n = 0
	map.floorTiles = {}
	map.walkers = { { x=0, y=0, dir=0 } }
end

function isComplete(map)  return map.n >= map.max  end

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
	while not isComplete(map) do
		generationStep(map)
	end
	return map
end

function generationStep(map)
	if math.random() <= map.branchChancePerStep then
		w = map.walkers[math.random(#map.walkers)]
		wNew = {
			x = w.x,
			y = w.y,
			dir = (w.dir + math.random(0,3)) % 4
		}
		table.insert(map.walkers, wNew)
	end

	for w = 1,#map.walkers do
		addRandomRoom(map, map.walkers[w])
		moveRandomly(map, map.walkers[w])
	end
end

function addRandomRoom(map, walker)
	local room = map.rooms[randomChoice(map.roomChances)]
	addRoom(map, room, walker.x, walker.y)
	walker.exits = room.exits
end

function addRoom(map, room, x, y)
	for i=1,#room.tiles do
		local t = room.tiles[i]
		addTile(map, x + t[1], y + t[2])
	end
end

function addTile(map, x, y)
	local key = tostring(x) .. ',' .. tostring(y)
	if map.floorTiles[key] == nil then
		map.floorTiles[key] = {x, y}
		map.n = map.n + 1
	end
end

function moveRandomly(map, walker)
	local turn = randomChoice(map.dirChances) - 1
	walker.dir = (walker.dir + turn) % 4
	local e = walker.exits[walker.dir+1]
	walker.x = walker.x + e[1]
	walker.y = walker.y + e[2]
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
