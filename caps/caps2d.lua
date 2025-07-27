CenterMargin = Enum(
	"CenterMargin", "TOP_LEFT", "TOP_CENTER", "TOP_RIGHT",
	"CENTER_LEFT", "CENTER", "CENTER_RIGHT",
	"BOTTOM_LEFT", "BOTTOM_CENTER", "BOTTOM_RIGHT")
--- Basic 2D Capabilities
--- @type table
local Caps2D = {
	--- Position of the object.
	--- @class Vec2(x, y)
	position = dovey.math.Vec2(0, 0),
	--- Scale of the object.
	--- @class Vec2(x, y)
	scale = dovey.math.Vec2(1, 1),
	--- Tranformation origin
	--- @class Vec2(x, y)
	origin = dovey.math.Vec2(0, 0),
	--- Where should origin affect the object.
	--- @enum CenterMargin
	margin = CenterMargin.TOP_LEFT,
	--- Skew/Shear Factor.
	--- @class Vec2(0, 0)
	shear = dovey.math.Vec2(0, 0),
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
		return { Tint.fromHex(value) }
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
---
--- Can be rgba values (with a being optional), a hex code such as #RRGGBB(AA) or #RGB(A)
--- @param ... table|string
function Caps2D:setTint(...)
	local t = { ... }
	if #t == 1 then t = ... end
	self.tint = normaliseTint(t)
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

--- Returns the dimensions (width and height) of this 2D Object.
---
--- Default is (1, 1), Please override.
--- @return number, number
function Caps2D:getDimensions()
	return 1, 1
end

--- Returns margin offsets based on the given enum value (or self.margin).
--- @return number, number
function Caps2D:getMarginOffset(marginType, width, height)
	local x, y = 0, 0
	if marginType == CenterMargin.TOP_CENTER or 
	   marginType == CenterMargin.CENTER or 
	   marginType == CenterMargin.BOTTOM_CENTER then
		x = width / 2
	elseif marginType == CenterMargin.TOP_RIGHT or 
		   marginType == CenterMargin.CENTER_RIGHT or 
		   marginType == CenterMargin.BOTTOM_RIGHT then
		x = width
	end
	if marginType == CenterMargin.CENTER_LEFT or 
	   marginType == CenterMargin.CENTER or 
	   marginType == CenterMargin.CENTER_RIGHT then
		y = height / 2
	elseif marginType == CenterMargin.BOTTOM_LEFT or 
		   marginType == CenterMargin.BOTTOM_CENTER or 
		   marginType == CenterMargin.BOTTOM_RIGHT then
		y = height
	end
	return x, y
end

return Caps2D
