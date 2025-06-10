local Sprite = Proto:extend({
	tint = nil, --- Colour of the Sprite when rendering.
	texture = nil, --- Texture to render the Sprite with.
	scale = nil, --- Display Size of the Texture.
	position = nil, --- Screen coordinates where the Texture renders.
	origin = nil, --- Texture Pivot Offset.
	shear = nil, --- Skew/Shear Factor.
	angle = 0, --- Texture Rotation Angle.
})

local function resetTransform(self)
	return self.position.get(), self.angle, self.scale.get(), self.origin.get(), self.shear.get()
end

--- Creates a Sprite (must be added to a Canvas to be displayed).
--- @param x 		(Initial) X Coordinates to Display the Sprite at.
--- @param y 		(Initial) Y Coordinates to Display the Sprite at.
--- @param texture 	Texture to render the Sprite, you can set it at anytime with Sprite:loadTexture()
function Sprite:init(x, y, texture)
	-- these have to be set here, setting it on :extend crashes :(
	self.tint = { Tint.fromRGB(255, 255, 255, 255) }
	self.position = Vec2(x or 0, y or 0)
	self.scale = Vec2(1, 1)
	self.origin = Vec2(0, 0)
	self.shear = Vec2(0, 0)
	if texture then self:loadTexture(texture) end
	return self
end

local _white = {1,1,1,1}

function Sprite:draw()
	love.graphics.push("all")

	love.graphics.translate(self.position.get()) -- Positioning
	love.graphics.rotate(self.angle) -- Rotation
	love.graphics.scale(self.scale.get()) -- Scale
	love.graphics.shear(self.shear.x, self.shear.y) -- Skewing
	love.graphics.translate(-self.origin.x, -self.origin.y) -- Pivot Offset
	love.graphics.setColor(self.tint or _white) -- Colouring

	if self.texture then love.graphics.draw(self.texture) end
	love.graphics.setColor(_white)
	love.graphics.pop()
end

--- Loads a Texture to The Sprite in order to render it.
---
--- Caching the texture beforehand is recommended if you're not doing it frequently.
function Sprite:loadTexture(tex)
	self.texture = type(tex) == "string" and love.graphics.newTexture(tex) or tex
	return self
end

--- Repositions the Sprite elsewhere.
function Sprite:setPosition(x, y)
	self.position.set(x or 0, y or 0)
	return self
end

--- Returns the dimensions (width and height) of the Sprite's texture.
function Sprite:getDimensions()
	local w, h = 1, 1
	if self.texture then
		w, h = self.texture:getWidth(), self.texture:getHeight()
	end
	return w, h
end

--- Returns the width of the Sprite's texture.
function Sprite:getWidth() return self.texture and self.texture:getWidth() or 1 end
--- Returns the height of the Sprite's texture.
function Sprite:getHeight() return self.texture and self.texture:getHeight() or 1 end

--- Positions the Sprite at the center of the screen
--- @param x 		How much to offset the X position when centering.
--- @param y 		How much to offset the Y position when centering.
function Sprite:centerPosition(x, y)
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
function Sprite:setScale(x, y)
	self.scale.set(x or 1, y or 1)
	return self
end

--- Applies a shear factor (skew) to the Sprite.
--- @param x 		How much to shear the Sprite on the X axis.
--- @param y 		How much to shear the Sprite on the Y axis.
function Sprite:setShear(x, y)
	self.shear.set(x or 0, y or 0)
	return self
end

--- Applies a new rotation angle to the Sprite.
function Sprite:setAngle(angle)
	self.angle = angle or 0
	return self
end

--- Changes the render colour of the Sprite.
--- @param r 		How much Red (range is: 0-255)
--- @param g 		How much Green (range is: 0-255)
--- @param b 		How much Blue (range is: 0-255)
--- @param a 		How much Alpha (range is: 0-255)
function Sprite:setTint(r, g, b, a)
	self.tint = { Tint.fromRGB(r or 255, g or 255, b or 255, a or 255) }
	return self
end

return Sprite
