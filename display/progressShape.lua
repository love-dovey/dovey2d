ProgressStyling = {
	Direction = Enum("ProgressStylingDirection", "LeftRight", "RightLeft", "TopBottom", "BottomTop"), --- Horizontal Directions.
	Shape = Enum("ProgressStylingShape", "RECTANGLE", "CIRCLE", "DIAMOND"),                        --- Render Shapes.
}

local _defaultTint = {
	{ 0, 0.5, 0, 1 }, -- Dark Green
	{ 0, 1.0, 0, 1 }, -- Green
}

local Caps2D = require("dovey.caps.caps2d")
local ProgressShape = Object:extend({
	_name = "ProgressShape",
	size = Vec2(350, 25),                         -- Width and Height of the shape.
	direction = ProgressStyling.Direction.LeftRight, --- Where should Colour 1 and Colour 2 be rendered?
	smooth = false,                               --- Smoothly transitions between colour 1 and 2 when rendering.
	current = 0,                                  --- Current value.
	maximum = 100,                                --- Maximum value that can be to reach.
	minimum = 0,                                  --- Minimum value that can be to reach.
	rounded = true,                               --- Maintains the value in a linear range (always round numbers, never decimals).
}):implement(Caps2D)

local tints = {    --- Contains the colours to render the background and progress.
	{ 0, 0.5, 0, 1 }, -- Dark Green
	{ 0, 1.0, 0, 1 }, -- Green
}
local border = {   --- Handles the border behind the main colours.
	tint = { 1, 1, 1, 1 },
	thickness = 3,
}

--- Creates a ProgressShape, which is a special type of Display Object
--- which has the capacity to render as a Health/Progress meter.
---
--- @param x number
--- @param y number
--- @param dir string|number 		Options: "LeftRight"|1, "RightLeft"|2, "TopBottom"|3, "BottomTop"|4
function ProgressShape:init(x, y, dir)
	self.position:set(x or self.position.x, y or self.position.y)
	self.direction = ProgressStyling.Direction.resolve(dir or self.direction)
	return self
end

--- Sets the current progress value.
--- @param value number
function ProgressShape:setProgress(value)
	self.current = math.max(self.minimum, math.min(self.maximum, value))
	if self.rounded then self.current = math.floor(self.current + 0.5) end
	return self
end

--- Checks if we've reached the end of the progress meter.
function ProgressShape:isFull() return self.current >= self.maximum end

--- Checks if we are at the start of the progress meter.
function ProgressShape:isEmpty() return self.current <= self.minimum end

function ProgressShape:draw()
	if self.visible == false then return end
	love.graphics.push("all")

	love.graphics.translate(self.position.x, self.position.y) -- Positioning
	love.graphics.rotate(self.rotation)                    -- Rotation
	love.graphics.scale(self.scale.x, self.scale.y)        -- Scale
	love.graphics.shear(self.shear.x, self.shear.y)        -- Skewing
	love.graphics.translate(-self.origin.x, -self.origin.y) -- Pivot Offset

	if border.thickness > 0 and border.tint[4] > 0 then
		love.graphics.setColor(border.tint)
		love.graphics.setLineWidth(border.thickness or 1)
		love.graphics.rectangle("line", 0, 0, self.size.x, self.size.y)
	end

	love.graphics.setColor(tints[1] or _defaultTint[1])                         -- Draw Background
	love.graphics.rectangle("fill", 0, 0, self.size.x, self.size.y)
	local sizeProg = (self.current - self.minimum) / (self.maximum - self.minimum) -- I think, i hope.
	love.graphics.setColor(tints[2] or _defaultTint[2])                         -- Draw Progress
	local nx = 0
	if self.direction == ProgressStyling.Direction.RightLeft then
		sizeProg = 1 - sizeProg
		nx = self.size.x * sizeProg
	end
	love.graphics.rectangle("fill", nx, 0, self.size.x * sizeProg, self.size.y)
	love.graphics.pop()
end

--- Returns the dimensions (width and height) of the ProgressShape.
function ProgressShape:getDimensions() return self.size.x or 1, self.size.y or 1 end

--- Returns the width of the ProgressShape.
function ProgressShape:getWidth() return self.size.x or 1 end

--- Returns the height of the ProgressShape.
function ProgressShape:getHeight() return self.size.y or 1 end

--- Positions the ProgressShape at the center of the screen
--- @param x number		How much to offset the X position when centering.
--- @param y number		How much to offset the Y position when centering.
function ProgressShape:centerPosition(x, y)
	self:centerX(x)
	self:centerY(y)
	return self
end

--- Positions the ProgressShape at the center of the screen on the X axis
--- @param x number		How much to offset the X position when centering.
function ProgressShape:centerX(x)
	x = x or 0
	local slx = self.scale.x
	local szx = self:getWidth()
	local wx = love.window.getMode()
	self.position.x = (wx - (szx * slx)) * 0.5 + x
	return self
end

--- Positions the ProgressShape at the center of the screen on the Y axis
--- @param y number		How much to offset the Y position when centering.
function ProgressShape:centerY(y)
	y = y or 0
	local sly = self.scale.y
	local szy = self:getHeight()
	local _, wy = love.window.getMode()
	self.position.y = (wy - (szy * sly)) * 0.5 + y
	return self
end

local function normaliseTint(value)
	if type(value) == "string" then
		return { Tint.fromHex(value) }
	elseif type(value) == "table" then
		if value[1] > 1 or value[2] > 1 or value[3] > 1 then
			return { Tint.fromBytes(table.unpack(value)) }
		end
		return value
	end
	return { 1, 1, 1, 1 }
end

--- Changes the render colour for the background.
---
--- Can be rgba values (with a being optional), a hex code such as #RRGGBB(AA) or #RGB(A)
function ProgressShape:setBackgroundTint(...)
	local t = { ... }
	if #t == 1 then t = ... end
	tints[1] = normaliseTint(t)
	return self
end

--- Changes the render colour for the foreground/progress.
---
--- Can be rgba values (with a being optional), a hex code such as #RRGGBB(AA) or #RGB(A)
function ProgressShape:setProgressTint(...)
	local t = { ... }
	if #t == 1 then t = ... end
	tints[2] = normaliseTint(t)
	return self
end

--- Sets the border's tint and thickness at the same time.
--- @param thickness number 	Thickness of the border, a low value is recommended.
--- @param ... any				This value is converted to a color.
function ProgressShape:setBorder(thickness, ...)
	local t = { ... }
	if #t == 1 then t = ... end
	border.tint = normaliseTint(t)
	border.thickness = thickness or 0
	return self
end

--- Changes the render colour for the border.
---
--- Can be rgba values (with a being optional), a hex code such as #RRGGBB(AA) or #RGB(A)
function ProgressShape:setBorderTint(...)
	local t = { ... }
	if #t == 1 then t = ... end
	border.tint = normaliseTint(t)
	return self
end

--- Changes how thick the border behind the background and fill tints should be.
--- @param x number
function ProgressShape:setBorderThickness(x)
	border.thickness = x or 0
	return self
end

return ProgressShape
