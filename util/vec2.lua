--- A Data closure that represents a Point/Vector, has 2D Coordinates (X, Y)
local function Vec2(x, y)
	local self = { x = x or 0, y = y or 0 }
	self._name = "Vec2"
	function self.set(x, y)
		self.x, self.y = x, y
		return self
	end
	function self.zero()
		self.x, self.y = 0, 0
		return self
	end
	function self.one()
		self.x, self.y = 1, 1
		return self
	end
	function self.get()
		return self.x, self.y
	end
	function self.add(x, y)
		self.x = self.x + x
		self.y = self.y + y
		return self
	end
	function self.addVec2(ovec2)
		self.x = self.x + ovec2.x
		self.y = self.y + ovec2.y
		return self
	end
	function self.round()
		self.x = math.floor(self.x + 0.5)
		self.y = math.floor(self.y + 0.5)
		return self
	end
	function self.__tostring() -- does this even work outside metatables
		return ("Vec2(%f, %f)"):format(self.x, self.y)
	end
	return self
end

return Vec2
