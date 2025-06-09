local function makeEnum(...)
	local newEnum = {...}
	-- Reverse mappings are stored both for number AND for string.
	for k,v in pairs(newEnum) do newEnum[v] = k end
	newEnum.str = function(t)
		for k,v in pairs(newEnum) do
			if v == t then return k end
		end
	end
	-- FAANCY motherfucker
	newEnum.resolve = function(input)
		if type(input) == "number" then
			return math.floor(input+0.5)
		elseif type(input) == "string" then
			input = input:lower():gsub("%s+","")
			return newEnum[input:upper()] or newEnum[newEnum[1]]
		end
		return newEnum[newEnum[1]]
	end
	return newEnum
end

return makeEnum
