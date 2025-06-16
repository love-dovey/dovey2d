LogLevel = Enum("LogLevel", "INFO", "WARN", "ERROR")
local asciiCodes = {
	white = "\27[0m",
	red = "\27[31m",
	yellow = "\27[33m",
	blue = "\27[34m",
}
local _warned = {}
local function printRich(msg, level)
	msg = tostring(msg)
	level = LogLevel.resolve(level)
	local info = debug.getinfo(2, "Sl")
	local line = info.short_src .. ":" .. info.currentline
	if arg[#arg] == "-subl" then -- no colours in sublime text.
		io.stderr:write("[" .. (Engine.engineName or "dövey") ..
		":" .. LogLevel.str(level) .. "] " .. msg .. " (at: " .. line .. ")\n")
		return
	end
	local col = asciiCodes.white
	if level == 1 then
		col = asciiCodes.blue
	elseif level == 2 then
		col = asciiCodes.yellow
	elseif level == 3 then
		col = asciiCodes.red
	end
	io.stderr:write(
		col .. "[Dövey:" .. LogLevel.str(level) .. "] " ..
		asciiCodes.white .. msg ..
		" (at: " .. line .. ")\n")
end
return {
	_name = "Log",
	info = function(msg)
		return printRich(msg, LogLevel.INFO)
	end,
	warn = function(msg, once)
		if once then
			if _warned[msg] == true then return end
			_warned[msg] = true
		end
		return printRich(msg, LogLevel.WARN)
	end,
	error = function(msg, errLevel, once)
		if once then
			if _warned[msg] == true then return end
			_warned[msg] = true
		end
		return printRich(msg, LogLevel.ERROR, errLevel)
	end,
}
