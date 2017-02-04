-- Walk around randomly to fill the table.

function love.load()
	tSz = 16

	map = newMap(150)
	generateMap(map, 0)

	love.graphics.setBackgroundColor(36, 33, 18)
	love.graphics.setColor(30, 140, 22)
end

function love.draw()
	drawMap(map)
end

function drawMap(map)
	for k,v in pairs(map.floorTiles) do
		drawFloor(v[1], v[2])
	end
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

function generateMap(map, seed)
	math.randomseed(seed)
	while placeFloor(map, map.x, map.y) do
		moveRandomly(map)
	end
	return map
end

function placeFloor(map, x, y)
	local canPlace = map.n < map.max
	if canPlace then
		local key = tostring(x) .. ',' .. tostring(y)
		if map.floorTiles[key] == nil then
			map.floorTiles[key] = {x, y}
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
