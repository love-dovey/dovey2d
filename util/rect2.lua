--- A Data closure that represents a Rectangle, has position and size.
local function Rect2(x, y, w, h)
	local self = { x = x or 0, y = y or 0, w = w or 0, h = h or 0, }
	self._name = "Rect2"
	function self.position() return self.x, self.y end
	function self.size() return self.w, self.h end
	function self.area() return self.w * self.h end
	function self.center() return (self.x + self.w * 0.5), (self.y + self.h * 0.5) end
	function self.set(x, y, w, h)
		self.x = x
		self.y = y
		self.w = w
		self.h = h
		return self
	end
	function self.get()
		return self.x, self.y, self.w, self.h
	end
	function self.add(x, y, w, h)
		self.x = self.x + x
		self.y = self.y + y
		self.w = self.w + w
		self.h = self.h + h
		return self
	end
	function self.addRect2(orect2)
		self.x = self.x + orect2.x
		self.y = self.y + orect2.y
		self.w = self.w + orect2.w
		self.h = self.h + orect2.h
		return self
	end
	function self.round()
		self.x = math.floor(self.x + 0.5)
		self.y = math.floor(self.y + 0.5)
		self.w = math.floor(self.w + 0.5)
		self.h = math.floor(self.h + 0.5)
		return self
	end
	function self.overlaps(r)
		return self.x < r.x + r.w and
			self.x + self.w > r.x and
			self.y < r.y + r.h    and
			self.y + self.h > r.y
	end
	function self.__tostring()
		return ("Rect2(%d, %d, %d, %d)"):format(self.x, self.y, self.w, self.h)
	end
	return self
end

return Rect2
