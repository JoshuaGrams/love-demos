-- Add load function, draw the rectangles from a table.

function love.load()
	tSz = 16

	map = {
		['10,10'] = { 10, 10 },
		['11,12'] = { 11, 12 },
		['12,12'] = { 12, 12 }
	}

	love.graphics.setBackgroundColor(36, 33, 18)
	love.graphics.setColor(30, 140, 22)
end

function drawMap(map)
	for k,v in pairs(map) do
		drawFloor(v[1], v[2])
	end
end

function drawFloor(x, y)
	love.graphics.rectangle("fill", x*tSz, y*tSz, tSz, tSz)
end

function love.draw()
	drawMap(map)
end
