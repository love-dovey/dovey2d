TextAlignment = Enum("TextAlignment", "LEFT", "CENTER", "RIGHT") --"FILL")
TextStroke = Enum("TextStroke", "NONE", "OUTLINE", "SHADOW")

local MAX_OUTLINE_ITERATIONS = 8
local DEFAULT_OUTLINE_SIZE = 1.25

-- half of this is taken from Sprite.lua

local Caps2D = require("dovey.caps.caps2d")

local TextDisplay = Proto:extend({
	_name = "TextDisplay",
	text = nil,                  --- Text displayed on-screen when visible.
	limit = 0,                   --- Limit (in screen pixels) before word wrapping starts.
	--- Enum("TextWrapMode", NONE", "SIMPLE", "SMART")?
	wrapText = true,             --- If word wrapping should happen when the text exceeds the limit.
	alignment = TextAlignment.LEFT, --- Where should text align to (based on limit).
	stroke = nil,                --- Shadow/Outline behind text. @type table
	font = nil,                  --- Per instance font. @type love.Font
}):implement(Caps2D)

local function getDefaultStroke()
	return {
		size = DEFAULT_OUTLINE_SIZE, -- Stroke size.
		tint = { 0, 0, 0, 1 }, -- Stroke Tint/Colour.
		offset = { x = -5, y = 5 }, -- Offset (for shadows)
		type = TextStroke.NONE, -- Text Stroke type.
	}
end

--local function resetTransform(self)
--	return self.position:get(), self.rotation, self.scale:get(), self.origin:get(), self.shear:get()
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
	if self.visible == false then return end
	love.graphics.push("all")

	love.graphics.translate(self.position.x, self.position.y) -- Positioning
	love.graphics.rotate(self.rotation)                    -- Rotation
	love.graphics.scale(self.scale.x, self.scale.y)        -- Scale
	love.graphics.shear(self.shear.x, self.shear.y)        -- Skewing
	love.graphics.translate(-self.origin.x, -self.origin.y) -- Origin
	love.graphics.setFont(self.font)

	self:drawCurrentText(self.text, self.tint, self.stroke)
	love.graphics.pop()
end

-- override this if needed
function TextDisplay:drawCurrentText(text, tint, stroke)
	if stroke and stroke.type ~= TextStroke.NONE and stroke.size > 0 then
		love.graphics.setColor(stroke.tint)
		if self.stroke.type == TextStroke.OUTLINE then
			-- i hate this already, i should use a shader, but it looks ugly.
			local off = -self.stroke.size
			--- @diagnostic disable-next-line: unused-local -- you're gonna shut up.
			for _ = 1, MAX_OUTLINE_ITERATIONS do
				self:drawText(text, 0, off)
				self:drawText(text, off, 0)
				self:drawText(text, -off, off)
				self:drawText(text, off, -off)
				off = -off
			end
		else -- Shadow
			local off = stroke.offset or { x = 1, y = 1 }
			self:drawText(text, off.x, off.y)
		end
	end
	love.graphics.setColor(tint) -- Colouring
	self:drawText(text)
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

--- Changes the offset of the Drop Shadow stroke.
--- @param ox number
--- @param oy number
function TextDisplay:setStrokeOffset(ox, oy)
	ox, oy = ox or 0, oy or 0
	if type(self.stroke) ~= "table" then
		-- in case you cleared it for some reason
		self.stroke = getDefaultStroke()
	end
	self.stroke.offset.x = ox
	self.stroke.offset.y = oy
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
