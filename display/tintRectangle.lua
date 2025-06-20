RectangleRenderMode = Enum("RectangleRenderMode", "FILL", "LINE") -- this is just for type safety actually.
local Caps2D = require("dovey.caps.caps2d")
local TintRectangle = Object:extend({
	_name = "TintRectangle",
	size = Vec2(50, 50),
	thickness = 0,
	mode = nil,
}):implement(Caps2D)

--- Creates a Tinted Rectangle.
--- @param x number		Initial X position
--- @param y number		Initial Y position
--- @param tint table	Colour { r, g, b, a }
--- @param sx number	Initial X size
--- @param sy number	Initial Y size
function TintRectangle:init(x, y, tint, sx, sy)
	self.position:set(x or self.position.x, y or self.position.y)
	if tint then
		self.tint = tint or { Tint.fromRGB(tint[1], tint[2], tint[3], tint[4] or 255) }
	end
	self.mode = RectangleRenderMode.resolve("FILL")
	self.size = Vec2(sx or self.size.x, sy or self.size.y)
	return self
end

function TintRectangle:draw()
	if self.visible == false then return end
	love.graphics.push("all")
	love.graphics.translate(self.position.x, self.position.y) -- Positioning
	love.graphics.rotate(self.rotation)                       -- Rotation
	love.graphics.scale(self.scale.x, self.scale.y)        -- Scale
	love.graphics.shear(self.shear.x, self.shear.y)        -- Skewing
	love.graphics.setColor(self.tint)                      -- Colouring
	love.graphics.setLineWidth(self.thickness or 1)        -- Line Thickness
	local mode = RectangleRenderMode.str(self.mode):lower()
	love.graphics.rectangle(mode, 0, 0, self.size.x, self.size.y)
	love.graphics.pop()
end

--- Positions the TintRectangle at the center of the screen
--- @param x number		How much to offset the X position when centering.
--- @param y number		How much to offset the Y position when centering.
function TintRectangle:centerPosition(x, y)
	self:centerX(x)
	self:centerY(y)
	return self
end

--- Positions the TintRectangle at the center of the screen on the X axis
--- @param x number		How much to offset the X position when centering.
function TintRectangle:centerX(x)
	x = x or 0
	local slx = self.scale.x
	local szx = self.size.x
	local wx = love.window.getMode()
	self.position.x = (wx - (szx * slx)) * 0.5 + x
	return self
end

--- Positions the TintRectangle at the center of the screen on the Y axis
--- @param y number		How much to offset the Y position when centering.
function TintRectangle:centerY(y)
	y = y or 0
	local sly = self.scale.y
	local szy = self.size.y
	local _, wy = love.window.getMode()
	self.position.y = (wy - (szy * sly)) * 0.5 + y
	return self
end

--- Defines how the TintRectangle will be rendered.
---
--- "fill"|1 Draws a filled shape, while "line"|2 Draws a outlined shape.
--- @param mode string|number
--- @param lineThickness number 		How thick should hte line be (for mode "line"|2)
function TintRectangle:setMode(mode, lineThickness)
	self.mode = RectangleRenderMode.resolve(mode)
	self.thickness = lineThickness or 1
	return self
end

--- Changes the overall size of the TintRectangle.
--- @param x number		How much to scale the TintRectangle on the X axis.
--- @param y number		How much to scale the TintRectangle on the Y axis.
function TintRectangle:setSize(x, y)
	self.size:set(x or 1, y or 1)
	return self
end

return TintRectangle
