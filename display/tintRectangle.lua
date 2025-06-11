RectangleRenderMode = Enum("FILL", "LINE") -- this is just for type safety actually.
local TintRectangle = Proto:extend({
	position = Vec2(0, 0),
	scale = Vec2(1, 1),
	size = Vec2(50, 50),
	shear = Vec2(0, 0),
	tint = {1, 1, 1, 1},
	thickness = 0,
	mode = nil,
	angle = 0,
})

--- Creates a Tinted Rectangle.
--- @param x number		Initial X position
--- @param y number		Initial Y position
--- @param tint table	Colour { r, g, b, a }
--- @param sx number	Initial X size
--- @param sy number	Initial Y size
function TintRectangle:init(x, y, tint, sx, sy)
	self.position = Vec2(x or self.position.x, y or self.position.y)
	if tint then
		self.tint = tint or { Tint.fromRGB(tint[1], tint[2], tint[3], tint[4] or 255) }
	end
	self.mode = RectangleRenderMode.resolve("FILL")
	self.size = Vec2(sx or self.size.x, sy or self.size.y)
	return self
end

function TintRectangle:draw()
	local prevTint = { love.graphics.getColor() }
	love.graphics.push("all")

	love.graphics.translate(self.position.get()) -- Positioning
	love.graphics.rotate(self.angle) -- Rotation
	love.graphics.scale(self.scale.get()) -- Scale
	love.graphics.shear(self.shear.x, self.shear.y) -- Skewing
	love.graphics.setColor(self.tint or prevTint) -- Colouring
	love.graphics.setLineWidth(self.thickness or 1) -- Line Thickness

	local mode = RectangleRenderMode.str(self.mode):lower()
	love.graphics.rectangle(mode, 0, 0, self.size.x, self.size.y)
	love.graphics.setColor(prevTint or Tint.WHITE)
	love.graphics.setLineWidth(1)
	love.graphics.pop()
end

--- Repositions the TintRectangle elsewhere.
function TintRectangle:setPosition(x, y)
	self.position.set(x or 0, y or 0)
	return self
end

--- Positions the TintRectangle at the center of the screen
--- @param x number		How much to offset the X position when centering.
--- @param y number		How much to offset the Y position when centering.
function TintRectangle:centerPosition(x, y)
	x, y = x or 0, y or 0
	local slx, sly = self.scale.get() -- X, Y
	local szx, szy = self.size.x, self.size.y -- Width, Height
	local wx, wy = love.window.getMode() -- Same as szx and szy
	self.position.set(
		(wx - (szx * slx)) * 0.5 + x,
		(wy - (szy * sly)) * 0.5 + y
	)
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

--- Scales the TintRectangle.
--- @param x number		How much to scale the TintRectangle on the X axis.
--- @param y number		How much to scale the TintRectangle on the Y axis.
function TintRectangle:setScale(x, y)
	self.scale.set(x or 1, y or 1)
	return self
end

--- Changes the overall size of the TintRectangle.
--- @param x number		How much to scale the TintRectangle on the X axis.
--- @param y number		How much to scale the TintRectangle on the Y axis.
function TintRectangle:setSize(x, y)
	self.size.set(x or 1, y or 1)
	return self
end

--- Applies a shear factor (skew) to the TintRectangle.
--- @param x number		How much to shear the TintRectangle on the X axis.
--- @param y number		How much to shear the TintRectangle on the Y axis.
function TintRectangle:setShear(x, y)
	self.shear.set(x or 0, y or 0)
	return self
end

--- Applies a new rotation angle to the TintRectangle.
function TintRectangle:setAngle(angle)
	self.angle = angle or 0
	return self
end

--- Changes the render colour of the TintRectangle.
--- @param r number		How much Red (range is: 0-255)
--- @param g number		How much Green (range is: 0-255)
--- @param b number		How much Blue (range is: 0-255)
--- @param a number		How much Alpha (range is: 0-255)
function TintRectangle:setTint(r, g, b, a)
	self.tint = { Tint.fromRGB(r or 255, g or 255, b or 255, a or 255) }
	return self
end

return TintRectangle
