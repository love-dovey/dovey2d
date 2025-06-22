--- Utility containing X and Y coordinates.
--- @class Vec2
local Vec2 = Object:extend {
	_name = "Vec2",
	x = 0, y = 0,
}

function Vec2:__tostring() -- does this even work outside metatables
	return ("Vec2(%f, %f)"):format(self.x, self.y)
end

function Vec2:init(x, y)
	self.x, self.y = x or self.x, y or self.y
	return self
end

function Vec2:set(x, y)
	self.x, self.y = x, y
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
	self.x = self.x + x
	self.y = self.y + y
	return self
end

function Vec2:addVec2(ovec2)
	self.x = self.x + ovec2.x
	self.y = self.y + ovec2.y
	return self
end

function Vec2:round()
	self.x = math.floor(self.x + 0.5)
	self.y = math.floor(self.y + 0.5)
	return self
end

return function(x, y)
	return Vec2:new(x, y)
end
