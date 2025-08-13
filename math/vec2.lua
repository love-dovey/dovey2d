--- Utility containing X and Y coordinates.
--- @class Vec2
local Vec2 = dovey.Object:extend {
	_name = "Vec2",
	x = x or 0, y = y or 0 }

function Vec2:__tostring() -- does this even work outside metatables
	return ("Vec2(%f, %f)"):format(self.x, self.y)
end

function Vec2:init(x, y)
	self.x, self.y = x or 0, y or 0
	return self
end

function Vec2:clone()
	return Vec2:new(self.x, self.y)
end

function Vec2:set(x, y)
	if type(x) ~= "number" and x.type and x:type() == "Vec2" then
		self.x, self.y = x.x, x.y
	elseif type(x) == "number" then
		self.x, self.y = x, y
	else
		error("[Vec2:set]: expected arguments (number, number) or (Vec2)")
	end
	return self
end

function Vec2:zero()
	self.x, self.y = 0, 0
	return self
end

function Vec2:one()
	self.x, self.y = 1, 1
	return self
end

function Vec2:get()
	return self.x, self.y
end

function Vec2:add(x, y)
	if type(x) ~= "number" and x.type and x:type() == "Vec2" then
		self.x, self.y = self.x + x.x, self.y + x.y
	elseif type(x) == "number" then
		self.x, self.y = self.x + x, self.y + y
	else
		error("[Vec2:add]: expected arguments (number, number) or (Vec2)")
	end
	return self
end

function Vec2:round()
	self.x = math.floor(self.x + 0.5)
	self.y = math.floor(self.y + 0.5)
	return self
end

function Vec2:distanceTo(other)
	local dx = other.x - self.x
	local dy = other.y - self.y
	return math.sqrt(dx * dx + dy * dy)
end

function Vec2:length()
	return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vec2:normalize()
	local len = self:length()
	if len > 0 then
		self.x = self.x / len
		self.y = self.y / len
	end
	return self
end

--- Limits the coordinates to a certain minimum and maximum
--- @param minx number 		minimum x position
--- @param maxx number 		maximum x position
--- @param miny number 		minimum y position
--- @param maxy number 		maximum y position
function Vec2:clamp(minx, maxx, miny, maxy)
	self.x = math.clamp(self.x, minx, maxx)
	self.y = math.clamp(self.y, miny, maxy)
	return self
end

--- @see Vec2:clamp
--- @param min Vec2
--- @param max Vec2
function Vec2:clampVec2(min, max)
	self.x = math.clamp(self.x, min.x, max.x)
	self.y = math.clamp(self.y, max.x, max.y)
	return self
end

--- Interpolates between `self` and `next`, `weight` represents a percentage (from 0 to 1).
---
--- @param next number 				Position to interpolate to.
--- @param weight number 			Percentage.
--- @return number
function Vec2:lerp(next, weight)
	self.x = math.lerp(self.x, next.x, weight)
	self.y = math.lerp(self.y, next.y, weight)
	return self
end

return function(x, y) return Vec2:new(x, y) end
