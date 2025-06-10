ProgressStyling = {
Direction = Enum("LeftRight", "RightLeft", "TopBottom", "BottomTop"), --- Horizontal Directions.
	Shape = Enum("RECTANGLE", "CIRCLE", "DIAMOND"), --- Render Shapes.
}

local _white = {1,1,1,1}
local _defaultTint = {
	{ 0, 0.5, 0, 1 }, -- Dark Green
	{ 0, 1.0, 0, 1 }, -- Green
}
local ProgressShape = Proto:extend({
	position = Vec2(0, 0), --- Position to render the ProgressShape at.
	scale = Vec2(1, 1), --- How much to stretch the ProgressShape to.
	size = Vec2(150, 30), -- Width and Height of the shape.
	angle = 0, --- Rotation Angle
	direction = ProgressStyling.Direction.LeftRight, --- Where should Colour 1 and Colour 2 be rendered?
	smooth = false, --- Smoothly transitions between colour 1 and 2 when rendering.
	current =   0, --- Current value.
	maximum = 100, --- Maximum value that can be to reach.
	minimum =   0, --- Minimum value that can be to reach.
	rounded = true, --- Maintains the value in a linear range (always round numbers, never decimals).
})
local tints = { --- Contains the colours to render the background and progress.
	{ 0, 0.5, 0, 1 }, -- Dark Green
	{ 0, 1.0, 0, 1 }, -- Green
}
local border = { --- Handles the border behind the main colours.
	tint = { 1, 1, 1, 1 },
	thickness = 3,
}

function ProgressShape:init(x, y, dir)
	self.position = Vec2(x or self.position.x, y or self.position.y)
	self.direction = ProgressStyling.Direction.resolve(dir or self.direction)
	return self
end

function ProgressShape:setProgress(value)
	self.current = math.max(self.minimum, math.min(self.maximum, value))
	if self.rounded then self.current = math.floor(self.current + 0.5) end
	return self
end
function ProgressShape:isFull() return self.current >= self.maximum end
function ProgressShape:isEmpty() return self.current <= self.minimum end

function ProgressShape:draw()
	love.graphics.push("all")
	-- rlly basic rendering should do it for now.
	-- reminder that Vec2.get() returns X and Y.

	love.graphics.translate(self.position.get()) -- Positioning
	love.graphics.rotate(self.angle) -- Rotation
	love.graphics.scale(self.scale.get()) -- Scale

	if border.thickness > 0 and border.tint[4] > 0 then
		love.graphics.setColor(border.tint or _white)
		love.graphics.setLineWidth(border.thickness or 1)
		love.graphics.rectangle("line", 0, 0, self.size.x, self.size.y)
	end

	love.graphics.setColor(tints[1] or _defaultTint[1]) -- Draw Background
	love.graphics.rectangle("fill", 0, 0, self.size.x, self.size.y)

	local sizeProg = (self.current - self.minimum) / (self.maximum - self.minimum) -- I think, i hope.
	love.graphics.setColor(tints[2] or _defaultTint[2]) -- Draw Progress
	if self.direction == ProgressStyling.Direction.RightLeft then
		sizeProg = 1 - sizeProg
	end
	love.graphics.rectangle("fill", 0, 0, self.size.x * sizeProg, self.size.y)

	love.graphics.setColor(_white)
	love.graphics.setLineWidth(1)
	love.graphics.pop()
end

-- just copied from sprite.lua lol

--- Repositions the ProgressBar elsewhere.
function ProgressShape:setPosition(x, y)
	self.position.set(x or 0, y or 0)
	return self
end

--- Returns the dimensions (width and height) of the ProgressShape.
function ProgressShape:getDimensions() return self.size.x or 1, self.size.y or 1 end
--- Returns the width of the ProgressShape.
function ProgressShape:getWidth() return self.size.x or 1 end
--- Returns the height of the ProgressShape.
function ProgressShape:getHeight() return self.size.y or 1 end

--- Positions the ProgressShape at the center of the screen
--- @param x 		How much to offset the X position when centering.
--- @param y 		How much to offset the Y position when centering.
function ProgressShape:centerPosition(x, y)
	x, y = x or 0, y or 0
	local slx, sly = self.scale.get() -- X, Y
	local szx, szy = self:getDimensions() -- Width, Height
	local wx, wy = love.window.getMode() -- Same as szx and szy
	self.position.set(
		(wx - (szx * slx)) * 0.5 + x,
		(wy - (szy * sly)) * 0.5 + y
	)
	return self
end

--- Scales the Sprite's texture.
--- @param x 		How much to scale the Sprite on the X axis.
--- @param y 		How much to scale the Sprite on the Y axis.
function ProgressShape:setScale(x, y)
	self.scale.set(x or 1, y or 1)
	return self
end

--- Applies a new rotation angle to the Sprite.
function ProgressShape:setAngle(angle)
	self.angle = angle or 0
	return self
end

--- Changes the render colour for the background.
--- @param r 		How much Red (range is: 0-255)
--- @param g 		How much Green (range is: 0-255)
--- @param b 		How much Blue (range is: 0-255)
--- @param a 		How much Alpha (range is: 0-255)
function ProgressShape:setBackgroundTint(r, g, b, a)
	tints[1] = { love.math.colorFromBytes(r or 0, g or 100, b or 0, a or 255) }
	return self
end

--- Changes the render colour for the foreground/progress.
--- @param r 		How much Red (range is: 0-255)
--- @param g 		How much Green (range is: 0-255)
--- @param b 		How much Blue (range is: 0-255)
--- @param a 		How much Alpha (range is: 0-255)
function ProgressShape:setProgressTint(r, g, b, a)
	tints[2] = { love.math.colorFromBytes(r or 0, g or 100, b or 0, a or 255) }
	return self
end

--- Sets the border's tint and thickness at the same time.
--- @param tint 		Table with 4 values { r, g, b, a }
--- @param thickness 	Thickness of the border, a low value is recommended.
--- @see https://love2d.org/wiki/love.math.colorFromBytes to use RGB(0-255).
function ProgressShape:setBorder(tint, thickness)
	border.tint = tint or { 1, 1, 1, 1 }
	border.thickness = thickness or 0
	return self
end

--- Changes the render colour for the border.
--- @param r 		How much Red (range is: 0-255)
--- @param g 		How much Green (range is: 0-255)
--- @param b 		How much Blue (range is: 0-255)
--- @param a 		How much Alpha (range is: 0-255)
function ProgressShape:setBorderTint(r, g, b, a)
	border.tint = { love.math.colorFromBytes(r or 0, g or 100, b or 0, a or 255) }
	return self
end

--- Changes how thick the border behind the background and fill tints should be.
function ProgressShape:setBorderThickness(x)
	border.thickness = x or 0
	return self
end

return ProgressShape
