TextAlignment = Enum("TextAlignment", "LEFT", "CENTER", "RIGHT") --"FILL")
TextStroke = Enum("TextStroke", "NONE", "OUTLINE", "SHADOW")

local MAX_OUTLINE_ITERATIONS = 8
local DEFAULT_OUTLINE_SIZE = 1.25

-- half of this is taken from Sprite.lua

local TextDisplay = Proto:extend({
	_name = "TextDisplay",
	text = nil,                  --- Text displayed on-screen when visible.
	tint = { 1, 1, 1, 1 },       --- Colour of the TextDisplay when rendering.
	scale = Vec2(1, 1),          --- Display Size of the Texture.
	position = Vec2(0, 0),       --- Screen coordinates where the Texture renders.
	origin = Vec2(0, 0),         --- Pivot Offset.
	shear = Vec2(0, 0),          --- Skew/Shear Factor.
	angle = 0,                   --- Text Rotation Angle.
	limit = 0,                   --- Limit (in screen pixels) before word wrapping starts.
	--- Enum("TextWrapMode", NONE", "SIMPLE", "SMART")?
	wrapText = true,             --- If word wrapping should happen when the text exceeds the limit.
	alignment = TextAlignment.LEFT, --- Where should text align to (based on limit).
	stroke = nil,                --- Shadow/Outline behind text. @type table
	font = nil,                  --- Per instance font. @type love.Font
})

local function getDefaultStroke()
	return {
		size = DEFAULT_OUTLINE_SIZE, -- Stroke size.
		tint = { 0, 0, 0, 1 }, -- Stroke Tint/Colour.
		offset = { x = -5, y = 5 }, -- Offset (for shadows)
		type = TextStroke.NONE, -- Text Stroke type.
	}
end

--local function resetTransform(self)
--	return self.position:get(), self.angle, self.scale:get(), self.origin:get(), self.shear:get()
--end

function TextDisplay:init(x, y, text, limit)
	self.stroke = getDefaultStroke()
	self.font = love.graphics.getFont()
	self.position:set(x or self.position.x, y or self.position.y)
	self.text = text or self.text
	self.limit = limit or self.limit
	if self.limit <= 0 then
		self.limit = love.graphics.getWidth()
	end
	return self
end

--- @param x? number
--- @param y? number
function TextDisplay:drawText(text, x, y)
	x, y = x or 0, y or 0
	local l = self.wrapText and self.limit or 0
	local align = TextAlignment.str(self.alignment):lower()
	love.graphics.printf(tostring(text), x, y, l, align)
end

function TextDisplay:draw()
	love.graphics.push("all")

	love.graphics.translate(self.position:get())         -- Positioning
	love.graphics.rotate(self.angle)                     -- Rotation
	love.graphics.scale(self.scale:get())                -- Scale
	love.graphics.shear(self.shear.x, self.shear.y)      -- Skewing
	love.graphics.translate(-self.origin.x, -self.origin.y) -- Origin
	love.graphics.setFont(self.font)
	self:drawCurrentText(self.text, self.tint, self.stroke.tint)
	love.graphics.pop()
end

-- override this if needed
function TextDisplay:drawCurrentText()
	if self.stroke and self.stroke.type ~= TextStroke.NONE and self.stroke.size > 0 then
		love.graphics.setColor(self.stroke.tint)
		if self.stroke.type == TextStroke.OUTLINE then
			-- i hate this already, i should use a shader, but it looks ugly.
			local off = -self.stroke.size
			--- @diagnostic disable-next-line: unused-local -- you're gonna shut up.
			for _ = 1, MAX_OUTLINE_ITERATIONS do
				self:drawText(self.text, 0, off)
				self:drawText(self.text, off, 0)
				self:drawText(self.text, -off, off)
				self:drawText(self.text, off, -off)
				off = -off
			end
		else -- Shadow
			local off = self.stroke.offset or { x = 1, y = 1 }
			self:drawText(self.text, off.x, off.y)
		end
	end
	love.graphics.setColor(self.tint) -- Colouring
	self:drawText(self.text)
	return self
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
			Log.error("Could not load font(" .. tostring(font) .. "), please pass (love.graphics.)Font to this function!")
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
	self.position:set(x or 0, y or 0)
	return self
end

--- Returns the dimensions (width and height) that are being rendered on the TextDisplay.
function TextDisplay:getDimensions()
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
	local szx, _ = self:getDimensions()
	self.position.x = (wx - (szx * slx)) * 0.5 + x
	return self
end

--- Positions the TextDisplay at the center of the screen on the Y axis
--- @param y number		How much to offset the Y position when centering.
function TextDisplay:centerY(y)
	y = y or 0
	local sly = self.scale.y
	local wy = love.window.getMode()
	local _, szy = self:getDimensions()
	self.position.y = (wy - (szy * sly)) * 0.5 + y
	return self
end

--- Scales the TextDisplay's font.
--- @param x number		How much to scale the TextDisplay on the X axis.
--- @param y number		How much to scale the TextDisplay on the Y axis.
function TextDisplay:setScale(x, y)
	self.scale:set(x or 1, y or 1)
	return self
end

--- Applies a shear factor (skew) to the TextDisplay.
--- @param x number		How much to shear the TextDisplay on the X axis.
--- @param y number		How much to shear the TextDisplay on the Y axis.
function TextDisplay:setShear(x, y)
	self.shear:set(x or 0, y or 0)
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

--- Changes which type of outline is rendered behind text.
--- @param x TextStroke|string|number
function TextDisplay:setStrokeType(x)
	if type(self.stroke) ~= "table" then
		-- in case you cleared it for some reason
		self.stroke = getDefaultStroke()
	end
	self.stroke.type = TextStroke.resolve(x)
	return self
end

--- Changes which type of outline is rendered behind text.
--- @param size number
function TextDisplay:setStrokeSize(size)
	assert(tonumber(size), "[TextDisplay:setStrokeSize] size must be a number!")
	if type(self.stroke) ~= "table" then
		-- in case you cleared it for some reason
		self.stroke = getDefaultStroke()
	end
	self.stroke.size = size
	return self
end

--- Changes the render colour of the outline behind the rendered text.
--- @param r number		How much Red (range is: 0-255)
--- @param g number		How much Green (range is: 0-255)
--- @param b number		How much Blue (range is: 0-255)
--- @param a number		How much Alpha (range is: 0-255)
function TextDisplay:setStrokeTint(r, g, b, a)
	if type(self.stroke) ~= "table" then
		-- in case you cleared it for some reason
		self.stroke = getDefaultStroke()
	end
	self.stroke.tint = { Tint.fromRGB(r or 255, g or 255, b or 255, a or 255) }
	return self
end

return TextDisplay
