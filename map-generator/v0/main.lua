function drawFloor(x, y)
	local tSz = 16
	love.graphics.rectangle("fill", x*tSz, y*tSz, tSz, tSz)
end

function love.draw()
	love.graphics.setBackgroundColor(36, 33, 18)
	love.graphics.setColor(30, 140, 22)
	drawFloor(10, 10)
	drawFloor(11, 12)
	drawFloor(12, 12)
end
