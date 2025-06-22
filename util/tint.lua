--- Utility with functions to resolve methods for colouring.
--- @type table
local Tint = {
	_name       = "Tint",
	TRANSPARENT = { 0, 0, 0, 0 },
	BLACK       = { 0, 0, 0, 1 },
	WHITE       = { 1, 1, 1, 1 },
	RED         = { 1, 0, 0, 1 },
	GREEN       = { 0, 1, 0, 1 },
	BLUE        = { 0, 0, 1, 1 },
}
local function clamp01(x) return math.min(math.max(x, 0), 1) end
local function fromBytes(r, g, b, a)
	a = a or 255
	return
		clamp01(r / 255),
		clamp01(g / 255),
		clamp01(b / 255),
		clamp01(a / 255)
end
local function toBytes(r, g, b, a)
	a = a or 1
	return
		math.floor(clamp01(r * 255 + 0.5)),
		math.floor(clamp01(g * 255 + 0.5)),
		math.floor(clamp01(b * 255 + 0.5)),
		math.floor(clamp01(a * 255 + 0.5))
end

--- Converts RGB (0-255) to (0-1) range.
function Tint.fromBytes(r, g, b, a)
	return fromBytes(r, g, b, a)
end

--- Converts RGB (0-1) to (0-255) range.
function Tint.toBytes(r, g, b, a)
	return toBytes(r, g, b, a)
end

--- Outputs a colour value (0-1) from an rgb value (0-255).
function Tint.fromRGB(r, g, b, a)
	a = a or 255
	if type(r) == "table" then
		return love.math.colorFromBytes(r[1], r[2] or 255, r[3] or 255, r[4] or 255)
	end
	return love.math.colorFromBytes(r, g, b, a)
end

--- Converts a hex value to a colour value (0-1).
--- @see https://love2d.org/wiki/love.math.colorFromBytes
function Tint.fromHex(rgba)
	rgba = rgba:gsub("#", "")     -- make sure there's no "#"
	local rb, gb, bb, ab = 0, 0, 0, 255
	if #rgba == 3 or #rgba == 4 then -- #RGBA
		rb = (tonumber(rgba:sub(1, 1), 16) * 17) or 0
		gb = (tonumber(rgba:sub(2, 2), 16) * 17) or 0
		bb = (tonumber(rgba:sub(3, 3), 16) * 17) or 0
		ab = #rgba == 8 and (tonumber(rgba:sub(7, 8), 16) or 255) or 255
	elseif #rgba == 6 or #rgba == 8 then -- #RRGGBBAA - Standard Hex Format (as far as i know.)
		rb = tonumber(rgba:sub(1, 2), 16) or 0
		gb = tonumber(rgba:sub(3, 4), 16) or 0
		bb = tonumber(rgba:sub(5, 6), 16) or 0
		ab = #rgba == 8 and (tonumber(rgba:sub(4, 4), 16) or 255) or 255
	end
	return fromBytes(rb, gb, bb, ab)
end

--- Converts a value to a hex code string.
--- @param rgba table
function Tint.toHex(rgba)
	local r, g, b, a = Tint.toBytes(table.unpack(rgba))
	return string.format("#%02x%02x%02x%02x", r, g, b, a)
end

--- Darkens a colour by a percentage (0-1)
function Tint.darken(value, amount)
	return {
		math.max(0, value[1] - amount), -- Red
		math.max(0, value[2] - amount), -- Green
		math.max(0, value[3] - amount), -- Blue
		value[4] or 1             -- Alpha
	}
end

--- Lightens a colour by a percentage (0-1)
function Tint.lighten(value, amount)
	return {
		math.min(1, value[1] + amount), -- Red
		math.min(1, value[2] + amount), -- Green
		math.min(1, value[3] + amount), -- Blue
		value[4] or 1             -- Alpha
	}
end

--- Multiplies colours A and B.
function Tint.multiply(a, b)
	return {
		a[1] * b[1],        -- Red
		a[2] * b[2],        -- Green
		a[3] * b[3],        -- Blue
		(a[4] or 1) * (b[4] or 1) -- Alpha
	}
end

function Tint.lerp(a, b, weight)
	weight = math.max(0, math.min(1, weight)) -- make sure it's not lower than 0 nor higher than 1
	local aAlpha = a[4] or 1
	local bAlpha = b[4] or 1
	return {
		a[1] + (b[1] - a[1]) * weight, -- Red
		a[2] + (b[2] - a[2]) * weight, -- Green
		a[3] + (b[3] - a[3]) * weight, -- Blue
		aAlpha + (bAlpha - aAlpha) * weight, -- Alpha
	}
end

return Tint
