TextAlignment = Enum("TextAlignment", "LEFT", "CENTER", "RIGHT") --"FILL")
TextStroke = Enum("TextStroke", "NONE", "OUTLINE", "SHADOW")

local DEFAULT_OUTLINE_SIZE = 1.25
local Caps2D = require("dovey.caps.caps2d")

local TextDisplay = Object:extend {
	_name = "TextDisplay",
	text = nil,                  --- Text displayed on-screen when visible.
	limit = 0,                   --- Limit (in screen pixels) before word wrapping starts.
	--- Enum("TextWrapMode", NONE", "SIMPLE", "SMART")?
	wrapText = true,             --- If word wrapping should happen when the text exceeds the limit.
	alignment = TextAlignment.LEFT, --- Where should text align to (based on limit).
	stroke = nil,                --- Shadow/Outline behind text. @type table
	font = nil,                  --- Per instance font. @type love.Font
}:implement(Caps2D)

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

function TextDisplay:drawStroke(text, stroke)
	if not stroke or stroke.type == TextStroke.NONE or stroke.size <= 0 then return end
	love.graphics.setColor(stroke.tint)
	if stroke.type == TextStroke.OUTLINE then
		local sz = self.stroke.size
		local offs = {
			{ -sz, 0 }, { sz, 0 }, { 0, -sz }, { 0, sz },
			{ -sz, -sz }, { -sz, sz }, { sz, -sz }, { sz, sz },
		}
		for _, offset in ipairs(offs) do
			self:drawText(text, offset[1], offset[2])
		end
	else -- Shadow
		local off = stroke.offset or { x = 1, y = 1 }
		self:drawText(text, off.x, off.y)
	end
	return self
end

-- override this if needed
function TextDisplay:drawCurrentText(text, tint, stroke)
	self:drawStroke(text, stroke)
	love.graphics.setColor(tint)
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
--- @param size? number Font size (optional) in case you're passing a string
--- @param upFilter? string(linear, nearest)
--- @param lowerFilter? string(linear, nearest)
function TextDisplay:setFont(font, size, upFilter, lowerFilter)
	if type(font) == "string" then
		upFilter = upFilter or "linear"
		lowerFilter = lowerFilter or "linear"
		assert(tonumber(size), "[TextDisplay:setFont]: size must be a number!")
		self.font = love.graphics.newFont(font, size)
		self.font:setFilter(upFilter, lowerFilter)
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
	self.text = text or "null (did you provide any?)"
	return self
end

--- Returns the dimensions (width and height) that are being rendered on the TextDisplay.
function TextDisplay:getDimensions()
	local w, h = 0, 0
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
	local w, h = 0, 0
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
	local wx = Engine.mainWindow.width
	local szx, _ = self:getDimensions()
	self.position.x = (wx - (szx * slx)) * 0.5 + x
	return self
end

--- Positions the TextDisplay at the center of the screen on the Y axis
--- @param y number		How much to offset the Y position when centering.
function TextDisplay:centerY(y)
	y = y or 0
	local sly = self.scale.y
	local wy = Engine.mainWindow.height
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

--- Changes the render colour of the outline behind the rendered text.
---
--- Can be rgba values (with a being optional), a hex code such as #RRGGBB(AA) or #RGB(A)
function TextDisplay:setStrokeTint(...)
	if type(self.stroke) ~= "table" then
		-- in case you cleared it for some reason
		self.stroke = getDefaultStroke()
	end
	local t = { ... }
	if #t == 1 then t = ... end
	self.stroke.tint = normaliseTint(t)
	return self
end

return TextDisplay
