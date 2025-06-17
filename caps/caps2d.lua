--- Basic 2D Capabilities
--- @type table
local Caps2D = {
	--- Position of the object.
	--- @class Vec2(x, y)
	position = Vec2(0, 0),
	--- Scale of the object.
	--- @class Vec2(x, y)
	scale = Vec2(1, 1),
	--- Tranformation origin
	--- @class Vec2(x, y)
	origin = Vec2(0, 0),
	--- Skew/Shear Factor.
	--- @class Vec2(0, 0)
	shear = Vec2(0, 0),
	--- Tint/Colour of the object.
	--- @type table {r, g, b, a}.
	tint = { 1, 1, 1, 1 },
	--- In radians.
	--- @type number
	rotation = 0,
	--- Visibility flag.
	--- @type boolean
	visible = true,
}

local function normaliseTint(value)
	if type(value) == "string" then
		return Tint.fromHex(value)
	elseif type(value) == "table" then
		if value[1] > 1 or value[2] > 1 or value[3] > 1 then
			return { Tint.fromBytes(table.unpack(value)) }
		end
		return value
	end
	return { 1, 1, 1, 1 }
end

--- Sets position directly.
--- @param x number
--- @param y number
function Caps2D:setPosition(x, y)
	x, y = x or 0, y or 0
	self.position:set(x, y)
	return self
end

--- Sets scaling directly.
--- @param x number
--- @param y number
function Caps2D:setScale(x, y)
	x, y = x or 0, y or 0
	self.scale:set(x, y)
	return self
end

--- Sets the tint to something else
--- @param value table|string
function Caps2D:setTint(value)
	self.tint = normaliseTint(value)
	return self
end

--- Moves the object by the provided offset.
--- @param x number
--- @param y number
function Caps2D:move(x, y)
	x, y = x or 0, y or 0
	self.position:set(self.position.x + x, self.position.y + y)
	return self
end

--- Rotate by radians.
--- @param radians number
function Caps2D:rotate(radians)
	radians = radians or 0
	self.rotation = self.rotation + radians
	return self
end

--- Multiplies scale by the numbers provided.
--- @param x number
--- @param y number
function Caps2D:scaleBy(x, y)
	x, y = x or 0, y or 0
	self.scale:set(self.scale.x * x, self.scale.y * y)
end

--- Adds to shear values with the numbers provided.
--- @param x number
--- @param y number
function Caps2D:setShear(x, y)
	x, y = x or 0, y or 0
	self.shear:set(self.shear.x + x, self.shear.y + y)
	return self
end

return Caps2D
