local LogLevel = Enum("LogLevel", "INFO", "WARN", "ERROR")
local asciiCodes = {
	white = "\27[0m",
	red = "\27[31m",
	yellow = "\27[33m",
	blue = "\27[34m",
}
local _warned = {}
local _errored = {}

local function formatMessage(...)
	local args = {...}
	local parts = {}
	for i = 1, select('#', ...) do
		local v = args[i]
		table.insert(parts, type(v) == "table" and string.table(msg) or tostring(v))
	end
	return table.concat(parts, "\t")
end

local function printRich(level, ...)
	local msg = formatMessage(...)
	level = LogLevel.resolve(level)
	local info = debug.getinfo(3, "Sl")  -- Go one level deeper
	local line = info.short_src .. ":" .. info.currentline
	if arg[#arg] == "-subl" then
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

--- Class for logging messages to standard output.
--- @type table
local Log = {
	_name = "Log",
	nativePrint = print
}

function Log.info(...)
	printRich(LogLevel.INFO, ...)
end

function Log.warn(...)
	local once = select(1, ...) == true
	local msg = formatMessage(select(once and 2 or 1, ...))
	if once then
		if _warned[msg] then return end
		_warned[msg] = true
	end
	printRich(LogLevel.WARN, msg)
end

function Log.error(...)
	local once = select(1, ...) == true
	local msg = formatMessage(select(once and 2 or 1, ...))
	if once then
		if _errored[msg] then return end
		_errored[msg] = true
	end
	printRich(LogLevel.ERROR, msg)
end

print = Log.info

return Log