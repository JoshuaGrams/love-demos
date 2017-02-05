
function love.load()

	verticalHexGrid = true
	keyboardLayout = 'qwerty'

	keypad = {
		['qwerty'] = {
			'q', 'w', 'e',
			'a', 's', 'd',
			'z', 'x', 'c'
		},
		-- Note: these are under your home-key fingers, *not*
		-- shifted to the left like the QWERTY keys (WASD) above.
		['dvorak'] = {
			",", '.', 'p',
			'o', 'e', 'u',
			'q', 'j', 'k'
		}
	}

	-- Fractions (a/b) for the square root of 3:
	--
	-- Hexes will be 2*a in the short direction (side to side)
	-- and 4*b in the long direction (point to point).
	--
	-- Spacing is 2*a in the side-to-side direction
	-- and 3*b in the point-to-point direction.
	--
	-- So hexes are 1.732 times (sqrt(3)) bigger in the
	-- point-to-point direction, but are spaced 1.155 times
	-- (sqrt(3) * 2/3) farther apart in the side-to-side
	-- direction.
	--
	-- * 71/41: error +0.0003435 (1 pixel per 2900 hexes)
	-- * 45/26: error +0.001282 (1 pixel per 800 hexes)
	-- * 26/15: error -0.001283 (1 pixel per 800 hexes)
	-- * 19/11: error +0.004778 (1 pixel per 200 hexes)
	-- * 12/7:  error +0.01777  (1 pixel per 50 hexes)

	a, b = 45, 26

	if verticalHexGrid then  -- flat top: clockwise from right
		hexPoints = {
			2*b,0,   b,a,  -b,a,
			-2*b,0,  -b,-a,  b,-a
		}
		hexWidth, hexHeight = 3*b, 2*a

		function hexToPixel(x, y)
			return x*3*b, (x + 2*y)*a
		end

		function rectToHex(x, y)
			return x, y - math.floor(x/2)
		end

		-- Use top two rows as three columns of two keys:
		-- up-left/down-left, up/down, up-right/down-right.
		local k = keypad[keyboardLayout]
		dirKeys = {
			[k[1]] = {-1,0},  [k[2]] = {0,-1}, [k[3]] = {1,-1},
			[k[4]] = {-1,1}, [k[5]] = {0,1}, [k[6]] = {1,0}
		}
	else  -- pointy top: clockwise from top
		hexPoints = {
			0,-2*b,  a,-b,   a,b,
			0,2*b,  -a,b,  -a,-b
		}
		hexWidth, hexHeight = 2*a, 3*b

		-- integer hex coordinates to pixel at hex center.
		function hexToPixel(x, y)
			return (2*x + y)*a, y*3*b
		end

		-- translate from rectangular block of hexagons
		-- to axial coordinates.
		function rectToHex(x, y)
			return x - math.floor(y/2), y
		end

		local k = keypad[keyboardLayout]
		dirKeys = {  -- note the redundancies (1=2, 5=8=9).
			[k[1]] = {0,-1}, [k[2]] = {0,-1}, [k[3]] = {1,-1},
			[k[4]] = {-1,0}, [k[5]] = {0,1}, [k[6]] = {1,0},
			[k[7]] = {-1,1}, [k[8]] = {0,1}, [k[9]] = {0,1}
		}
	end

	w = love.graphics.getWidth()
	h = love.graphics.getHeight()

	cursorX = math.floor(w/hexWidth/2)
	cursorY = math.floor(h/hexHeight/2)
	cursorX, cursorY = rectToHex(cursorX, cursorY)
end

function love.draw()
	for y=0,math.ceil(h/hexHeight) do
		for x=0,math.ceil(w/hexWidth) do
			drawHex(rectToHex(x, y))
		end
	end
	drawHex(cursorX, cursorY, true)
end

function drawHex(x, y, filled)
	x, y = hexToPixel(x, y)
	local points = {}
	for p=1,#hexPoints,2 do
		points[p] = x + hexPoints[p]
		points[p+1] = y + hexPoints[p+1]
	end
	local mode = 'line'
	if filled then mode = 'fill' end
	love.graphics.polygon(mode, points)
end

function love.keypressed(key)
	local dir = dirKeys[key]
	if dir then
		cursorX = cursorX + dir[1]
		cursorY = cursorY + dir[2]
	end
end
