TextAlignment = Enum("TextAlignment", "LEFT", "CENTER", "RIGHT") --"FILL")

-- half of this is taken from Sprite.lua

local TextDisplay = Proto:extend({
	_name = "TextDisplay",
	text = nil, --- Text displayed on-screen when visible.
	tint = { 1,1,1,1 }, --- Colour of the TextDisplay when rendering.
	scale = Vec2(1, 1), --- Display Size of the Texture.
	position = Vec2(0, 0), --- Screen coordinates where the Texture renders.
	origin = Vec2(0, 0), --- Pivot Offset.
	shear = Vec2(0, 0), --- Skew/Shear Factor.
	angle = 0, --- Text Rotation Angle.
	limit = 0, --- Limit (in screen pixels) before word wrapping starts.
	--- Enum("TextWrapMode", NONE", "SIMPLE", "SMART")?
	wrapText = true, --- If word wrapping should happen when the text exceeds the limit.
	alignment = TextAlignment.LEFT, --- Where should text align to (based on limit).
	font = nil, --- Per instance font.
})

local function resetTransform(self)
	return self.position.get(), self.angle, self.scale.get(), self.origin.get(), self.shear.get()
end

function TextDisplay:init(x, y, text, limit)
	self.font = love.graphics.getFont()
	self.position.set(x or self.position.x, y or self.position.y)
	self.text = text or self.text
	self.limit = limit or self.limit
	if self.limit <= 0 then
		self.limit = love.graphics.getWidth()
	end
	return self
end

function TextDisplay:draw()
	love.graphics.push("all")

	love.graphics.translate(self.position.get()) -- Positioning
	love.graphics.rotate(self.angle) -- Rotation
	love.graphics.scale(self.scale.get()) -- Scale
	love.graphics.shear(self.shear.x, self.shear.y) -- Skewing
	love.graphics.setColor(self.tint) -- Colouring

	love.graphics.setFont(self.font)

	local l = self.wrapText and self.limit or 0
	local align = TextAlignment.str(self.alignment):lower()
	love.graphics.printf(tostring(self.text), -self.origin.x, -self.origin.y, l, align)
	love.graphics.pop()
end

--- Changes the alignment of the text.
--- @param type number|TextAlignment
function TextDisplay:setAlignment(type)
	self.alignment = TextAlignment.resolve(type)
	return self
end

-- TODO: find a way to make a TextDisplay:setFontSize() function that can properly keep the font family.

--- Changes the font to a new one.
--- @param font string|love.graphics.Font
--- @param size Font size (optional) in case you're passing a string
function TextDisplay:setFont(font, size)
	if type(font) == "string" then
		assert(tonumber(size), "[TextDisplay:setFont]: size must be a number!")
		self.font = love.graphics.newFont(font, size)
	else
		if not font then
			Log.error("Could not load font("..tostring(font).."), please pass (love.graphics.)Font to this function!")
		end
		self.font = font or love.graphics.getFont()
	end
	return self
end

--- Changes what is displayed for something else (falls back if not possible).
--- @param text string
function TextDisplay:setText(text)
	self.text = text or ""
	return self
end

--- Repositions the TextDisplay elsewhere.
function TextDisplay:setPosition(x, y)
	self.position.set(x or 0, y or 0)
	return self
end

--- Returns the dimensions (width and height) that are being rendered on the TextDisplay.
function TextDisplay:getRenderDimensions()
	local w, h = 1, 1
	if self.font then
		if self.wrapText and self.limit > 0 then
			w = self.limit
			local _, lines = self.font:getWrap(self.text, self.limit)
			h = #lines * self.font:getLineHeight()
		else
			w, h = self.font:getWidth(self.text), self.font:getLineHeight()
		end
	end
	return w, h
end

--- Returns the dimensions (width and height) of the TextDisplay's font.
function TextDisplay:getFontDimensions()
	local w, h = 1, 1
	if self.font then
		w, h = self.font:getWidth(self.text), self.font:getLineHeight()
	end
	return w, h
end

--- Returns the width of the TextDisplay's font.
function TextDisplay:getWidth() return self.font and self.font:getWidth(self.text) or 1 end
--- Returns the height of the TextDisplay's font.
function TextDisplay:getHeight() return self.font and self.font:getLineHeight() or 1 end

--- Positions the TextDisplay at the center of the screen
--- @param x number		How much to offset the X position when centering.
--- @param y number		How much to offset the Y position when centering.
function TextDisplay:centerPosition(x, y)
	self:centerX(x)
	self:centerY(y)
	return self
end

--- Positions the TextDisplay at the center of the screen on the X axis
--- @param x number		How much to offset the X position when centering.
function TextDisplay:centerX(x)
	x = x or 0
	local slx = self.scale.x
	local wx = love.window.getMode()
	local szx, _ = self:getRenderDimensions()
	self.position.x = (wx - (szx * slx)) * 0.5 + x
	return self
end

--- Positions the TextDisplay at the center of the screen on the Y axis
--- @param y number		How much to offset the Y position when centering.
function TextDisplay:centerY(y)
	y = y or 0
	local sly = self.scale.y
	local wy = love.window.getMode()
	local _, szy = self:getRenderDimensions()
	self.position.y = (wy - (szy * sly)) * 0.5 + y
	return self
end

--- Scales the TextDisplay's font.
--- @param x number		How much to scale the TextDisplay on the X axis.
--- @param y number		How much to scale the TextDisplay on the Y axis.
function TextDisplay:setScale(x, y)
	self.scale.set(x or 1, y or 1)
	return self
end

--- Applies a shear factor (skew) to the TextDisplay.
--- @param x number		How much to shear the TextDisplay on the X axis.
--- @param y number		How much to shear the TextDisplay on the Y axis.
function TextDisplay:setShear(x, y)
	self.shear.set(x or 0, y or 0)
	return self
end

--- Applies a new rotation angle to the TextDisplay.
--- @param angle number
function TextDisplay:setAngle(angle)
	self.angle = angle or 0
	return self
end

--- Changes the render colour of the TextDisplay.
--- @param r number		How much Red (range is: 0-255)
--- @param g number		How much Green (range is: 0-255)
--- @param b number		How much Blue (range is: 0-255)
--- @param a number		How much Alpha (range is: 0-255)
function TextDisplay:setTint(r, g, b, a)
	self.tint = { Tint.fromRGB(r or 255, g or 255, b or 255, a or 255) }
	return self
end

return TextDisplay