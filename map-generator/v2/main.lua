-- Add placeFloor function to build table.

function love.load()
	tSz = 16

	map = { n=0, max=150, floorTiles = {} }
	placeFloor(map, 10, 10)
	placeFloor(map, 11, 12)
	placeFloor(map, 12, 12)

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
