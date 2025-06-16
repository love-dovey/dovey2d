--- Canvas for easily rendering objects to the screen.
local Canvas = Proto:extend({
	--- Canvas Name.
	_name = "Canvas",
	--- Contains the objects that render to the screen.
	objects = {},
	--- Returns the maximum amount of objects in the Canvas.
	length = function()
		return #self.objects
	end,
})

function Canvas:init()
	self.objects = {}
	return self
end

function Canvas:update(delta)
	self:forEach(function(o)
		if o.update then
			if getmetatable(o) then o:update(delta)
			else o.update(delta) end
		end
	end)
end

function Canvas:draw()
	self:forEach(function(o)
		if o.draw and o.exists then
			if getmetatable(o) then o:draw()
			else o.draw() end
		end
	end)
end

--- Adds an object to the Canvas.
---
--- @param o 			Object to add.
--- @param exclude		Toggles whether the object should be excluded from rendering.
function Canvas:add(o, exclude)
	local tbl = (not exclude and self.objects or self.exclusions)
	if not o then
		error("Tried to add Object("..tostring(o)..") to Canvas("..tostring(self._name or "CustomCanvas")..") at index "..#tbl+1)
		return nil
	end
	table.insert(tbl, o)
	if o.enterCanvas then o:enterCanvas() end
	return o
end

--- Removes an object from the Canvas.
---
--- @param o 			Object to get rid of.
function Canvas:remove(o)
	local function getRid(tbl)
		for i = #tbl, 1, -1 do
			if tbl[i] == o then
			    tbl[i] = tbl[#tbl]
			    tbl[#tbl] = nil
			    return true
			end
		end
		return false
	end
	return getRid(self.objects)
end

--- Clears the Canvas objects entirely.
function Canvas:clear()
	for _, o in ipairs(self.objects) do
		if o.exitCanvas then o:exitCanvas(self) end
	end
	self.objects = {}
end

--- Checks if an object is present inside the Canvas (excluded or not).
function Canvas:has(o)
    for _, v in ipairs(self.objects) do
    	if v == o then return true end
    end
    return false
end

--- Loops through every item in the Canvas.
---
--- @param fun 			Function to run on the objects looped.
function Canvas:forEach(fun)
	if fun then
		for idx, o in ipairs(self.objects) do fun(o, idx) end
	end
end

--- Layers items based on what the Z-layer variable is set to.
function Canvas:sortByZ()
	--TODO: implement Z ordering.
	return 0
end

return Canvas
