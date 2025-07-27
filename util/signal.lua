--- Utility to emit a signal to every attached function.
--- @class Signal
local Signal = dovey.Object:extend {
	_name = "Signal",
	timesEmitted = 0,
	funcs = {},
}

function Signal:init()
	return self
end

function Signal:connect(func)
	if type(func) ~= "function" then
		error("Attempt to assign a value(" ..
			tostring(func) .. ") of Type " ..
			type(func) .. " to a Signal when a Function was expected to be passed as a value.")
		return self
	end
	table.insert(self.funcs, func)
	return self
end

function Signal:disconnect(func)
	if type(func) ~= "function" then
		error("Attempt to assign a value(" ..
			tostring(func) .. ") of Type " ..
			type(func) .. " to a Signal when a Function was expected to be passed as a value.")
		return self
	end
	for i, target in pairs(self.funcs) do
		if func == target then
			table.remove(self.funcs, i)
			break
		end
	end
end

function Signal:hasConnection(func)
	if type(func) ~= "function" then
		error("Attempt to assign a value(" ..
			tostring(func) .. ") of Type " ..
			type(func) .. " to a Signal when a Function was expected to be passed as a value.")
		return self
	end
	local result = false
	for _, v in pairs(self.funcs) do
		if func == v then
			result = true
			break
		end
	end
	return result
end

function Signal:emit(...)
	self.timesEmitted = self.timesEmitted + 1
	for _, func in pairs(self.funcs) do
		-- easy !
		if func then
			func(...)
		else
			table.remove(self.funcs, _)
		end
	end
end

function Signal:dispose()
	for i = 1, #self.funcs do
		local fun = self.funcs[i]
		if fun then fun = nil end
	end
	self.funcs = nil
end

return Signal
