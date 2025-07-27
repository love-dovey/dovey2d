local Caps2D = require("dovey.caps.caps2d")

--- A neat little object that is used as an entry-point for any game.
---
--- This is used as a standalone way of rendering multiple objects to the screen.
--- @class Canvas
local Canvas = dovey.Object:extend {
	--- Canvas Name.
	--- @type string
	_name = "Canvas",
	--- Contains the objects that render to the screen.
	--- @type table
	objects = {},
}:implement(Caps2D)

function Canvas:init()
	self.objects = {}
	return self
end

function Canvas:update(delta)
	self:forEach(function(o)
		if o.update then
			if getmetatable(o) then
				o:update(delta)
			else
				o.update(delta)
			end
		end
	end)
end

function Canvas:draw()
	love.graphics.push("all")
	love.graphics.translate(self.position.x, self.position.y) -- Positioning
	love.graphics.rotate(self.rotation)                    -- Rotation
	love.graphics.scale(self.scale.x, self.scale.y)        -- Scale
	love.graphics.shear(self.shear.x, self.shear.y)        -- Skewing
	love.graphics.translate(-self.origin.x, -self.origin.y) -- Pivot Offset
	love.graphics.setColor(self.tint)                      -- Colouring

	self:forEach(function(o)
		if o.draw and o.exists then
			if getmetatable(o) then
				o:draw()
			else
				o.draw()
			end
		end
	end)
	love.graphics.pop()
end

--- Gets rid of anything in the Canvas.
function Canvas:dispose()
	local count = 1
	for k, v in pairs(self.objects) do
		if v and type(v) == "table" then
			if type(v.dispose) == "function" then
				if getmetatable(v) then
					v:dispose()
				else
					v.dispose()
				end
				count = count + 1
			else
				for i = 1, #v do
					if v.release then v:release() end
					if v ~= nil then v[i] = nil end
					count = count + 1
				end
			end
		end
		local nv = self.objects[k]
		if self.objects[k].release then self.objects[k]:release() end
		self.objects[k] = nil
		count = count + 1
	end
	--print(string.format("Canvas(%s) disposed %i objects cleared", self._name, count))
end

--- Adds an object to the Canvas.
---
--- @param o table|metatable			Object to add.
function Canvas:add(o)
	local tbl = self.objects
	if not o then
		error("Tried to add Object(" ..
			tostring(o) .. ") to Canvas(" .. tostring(self._name or "CustomCanvas") .. ") at index " .. #tbl + 1)
		return nil
	end
	table.insert(tbl, o)
	if o.enterCanvas then o:enterCanvas() end
	return o
end

--- Removes an object from the Canvas.
---
--- @param o table|metatable			Object to get rid of.
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

--- Returns the maximum amount of objects in the Canvas.
--- @return number
function Canvas:length()
	return #self.objects
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
--- @param fun function			Function to run on the objects looped.
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
