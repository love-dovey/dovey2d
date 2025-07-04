local Caps2D = require("dovey.caps.caps2d")

--- Object that displays a Texture.
--- @class Sprite
local Sprite = dovey.Object:extend {
	_name = "Sprite",
	texture = nil, --- Texture to render the Sprite with.
}:implement(Caps2D)

local function resetTransform(self)
	return self.position:get(), self.rotation, self.scale:get(), self.origin:get(), self.shear:get()
end

--- Creates a Sprite (must be added to a Canvas to be displayed).
--- @param x number		(Initial) X Coordinates to Display the Sprite at.
--- @param y number		(Initial) Y Coordinates to Display the Sprite at.
--- @param texture love.Texture	Texture to render the Sprite, you can set it at anytime with Sprite:loadTexture()
function Sprite:init(x, y, texture)
	self.position:set(x or self.position.x, y or self.position.y)
	if texture then self:loadTexture(texture) end
	return self
end

function Sprite:draw()
	if self.visible == false then return end
	love.graphics.push("all")

	love.graphics.translate(self.position.x, self.position.y) -- Positioning
	love.graphics.rotate(self.rotation)                    -- Rotation
	love.graphics.scale(self.scale.x, self.scale.y)        -- Scale
	love.graphics.shear(self.shear.x, self.shear.y)        -- Skewing
	love.graphics.translate(-self.origin.x, -self.origin.y) -- Pivot Offset
	love.graphics.setColor(self.tint)                      -- Colouring

	if self.texture then love.graphics.draw(self.texture) end
	love.graphics.pop()
end

--- Loads a Texture to The Sprite in order to render it.
---
--- Caching the texture beforehand is recommended if you're not doing it frequently.
--- @param tex String|love.graphics.Image
function Sprite:loadTexture(tex)
	self.texture = love.graphics.newTexture(tex)
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
--- @param x number		How much to offset the X position when centering.
--- @param y number		How much to offset the Y position when centering.
function Sprite:centerPosition(x, y)
	self:centerX(x)
	self:centerY(y)
	return self
end

--- Positions the Sprite at the center of the screen on the X axis
--- @param x number		How much to offset the X position when centering.
function Sprite:centerX(x)
	x = x or 0
	local slx = self.scale.x
	local szx = self:getWidth()
	local wx = Engine.mainWindow.width
	self.position.x = (wx - (szx * slx)) * 0.5 + x
	return self
end

--- Positions the Sprite at the center of the screen on the Y axis
--- @param y number		How much to offset the Y position when centering.
function Sprite:centerY(y)
	y = y or 0
	local sly = self.scale.y
	local szy = self:getHeight()
	local wy = Engine.mainWindow.height
	self.position.y = (wy - (szy * sly)) * 0.5 + y
	return self
end

return Sprite
