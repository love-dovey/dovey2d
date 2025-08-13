--- A 2D bounding-box, contains X and Y coordinates, and also width and height.s
--- @class Rect2
local Rect2 = dovey.Object:extend {
	_name = "Rect2",
	x = 0, y = 0,
	w = 0, h = 0
}

function Rect2:__tostring() -- does this even work outside metatables
	return ("Rect2(%f, %f, %f, %f)"):format(self.x, self.y, self.w, self.h)
end

function Rect2:init(x, y, w, h)
	self.x, self.y = x or self.x, y or self.y
	self.w, self.h = w or self.w, h or self.h
	return self
end

function Rect2:clone()
	return Rect2:new(self.x, self.y, self.w, self.h)
end

function Rect2:set(x, y, w, h)
	self.x, self.y = x, y
	self.w, self.h = w, h
	return self
end

function Rect2:zero()
	self.x, self.y = 0, 0
	self.w, self.h = 0, 0
	return self
end

function Rect2:one()
	self.x, self.y = 1, 1
	self.w, self.h = 1, 1
	return self
end

function Rect2:get() return self.x, self.y, self.w, self.h end

function Rect2:center() return (self.x + self.w * 0.5), (self.y + self.h * 0.5) end

function Rect2:area() return self.w * self.h end

function Rect2:position() return self.x, self.y end

function Rect2:size() return self.w, self.h end

function Rect2:add(x, y, w, h)
	self.x = self.x + x
	self.y = self.y + y
	self.w = self.w + w
	self.h = self.h + h
	return self
end

function Rect2:addRect2(orect2)
	self.x = self.x + orect2.x
	self.y = self.y + orect2.y
	self.w = self.w + orect2.w
	self.h = self.h + orect2.h
	return self
end

function Rect2:round()
	self.x = math.floor(self.x + 0.5)
	self.y = math.floor(self.y + 0.5)
	self.w = math.floor(self.w + 0.5)
	self.h = math.floor(self.h + 0.5)
	return self
end

--- Checks if a Rect2 overlaps another.
--- @param other Rect2
function Rect2:overlaps(other)
	local ax, ay, aw, ah = self.x, self.y, self.w, self.h
	local bx, by, bw, bh = other.x, other.y, other.w, other.h
	return ax < bx + bw and ax + aw > bx and ay < by + bh and ay + ah > by
end

--- Limits the position fo the Rectangle to a certain minimum and maximum.
--- @param minx number 		minimum x position
--- @param maxx number 		maximum x position
--- @param miny number 		minimum y position
--- @param maxy number 		maximum y position
function Rect2:clampPosition(minx, maxx, miny, maxy)
	self.x = math.clamp(self.x, minx, maxx)
	self.y = math.clamp(self.y, miny, maxy)
	return self
end

--- Limits the size of the Rectangle to a certain minimum and maximum.
--- @param minw number 		minimum width
--- @param maxw number 		maximum width
--- @param minh number 		minimum height
--- @param maxh number 		maximum height
function Rect2:clampSize(minw, maxw, minh, maxh)
	self.w = math.clamp(self.w, minw, maxw)
	self.h = math.clamp(self.h, minh, maxh)
	return self
end

return function(x, y, w, h) return Rect2:new(x, y, w, h) end
