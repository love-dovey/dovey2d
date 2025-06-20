local TRIM_PATTERN = "^%s*(.-)%s*$"
--local NO_BRACKETS_PATTERN = "[%[%]]"
local NO_QUOTE_PATTERN = "[\"']"

local function first(str, pat) return string.sub(str, 1, #pat) == pat end
local function last(str, pat) return string.sub(str, #str - #pat + 1, #str) == pat end
local function trim(str) return string.match(str, TRIM_PATTERN) end

function split(x, delimiter, seen)
	if #x == 0 then return {} end
	local function gsplit(s)
		table.insert(out, s)
	end
	out = seen or {}
	x = string.gsub(x, (delimiter and delimiter ~= "") and "([^" .. delimiter .. "]+)" or ".", gsplit)
	return out
end

local function tovalue(x)
	x = trim(string.gsub(string.gsub(x, "\"", ""), "'", ""))
	x = x:match("^%s*(.-)%s*$")
	if tonumber(x) then
		return tonumber(x)
	elseif x == "true" then
		return true
	elseif x == "false" then
		return false
	elseif first(x, "[") and last(x, "]") then
		-- Handles plain arrays (key=[value1, value2, value3])
		local xm = string.gsub(x, "[%[%]]", "")
		local tbl = split(xm, ",") or {}
		local t = {}
		for _, valueString in pairs(tbl) do
			table.insert(t, tovalue(valueString))
		end
		return t
	end
	return x
end

local doveyconf = {
	_NAME = "...",
	_DESCRIPTION = "A parser for INI/CFG/TOML-styled files.",
	_URL = "https://github.com/pisayesiwsi/dovey2d", -- maybe i should put this on its own repo some day.
	_VERSION = "1.0.0",
	_LICENSE = [[
		Copyright 2025 pisayesiwsi

		Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	]],
}

function doveyconf.multilineToTable(content)
	local result = {}
	for line in string.gmatch(content, "[^\r\n]+") do
		local row = {}
		for char in string.gmatch(line, ".") do table.insert(row, tonumber(char)) end
		for _, num in ipairs(row) do table.insert(result, num) end
	end
	return result
end

--- Parses the content of a custom INI/CFG/TOML-like string into a Lua table.
--- @param content string The full content of the configuration file.
--- @return table A Lua table representing the parsed configuration.
function doveyconf.parse(content)
	local file = {}
	local contable = split(content, "\n")
	local category = ""
	local i = 1

	while i <= #contable do
		local line = contable[i]
		local trimmed = trim(line)
		local isComment = first(trimmed, "#")

		if trimmed == "" then
			-- Skip empty lines
		elseif isComment then
			file.comments = file.comments or {}
			local comment = trimmed:sub(2):gsub(NO_QUOTE_PATTERN, "")
			table.insert(file.comments, trim(comment))
		elseif trimmed:match("^%[.-%]$") then
			category = trimmed:match("^%[(.-)%]$")
			-- nested arrays ([a.b.c] = file.a.b.c)
			local nested = split(category, ".")
			local current = file
			for _, subcat in pairs(nested) do
				if subcat ~= "" then
					current[subcat] = current[subcat] or {}
					current = current[subcat]
				end
			end
		elseif trimmed:find("=") then
			local keyv = split(trimmed, "=")
			local k = trim(keyv[1])
			local v = trim(keyv[2] or "")
			local target = file
			if category ~= "" then
				local cats = split(category, ".")
				for _, subcat in ipairs(cats) do
					target = target[subcat]
				end
			end

			if v == "[[" then
				-- Handle multiline string values ([[...]])
				local buffer = ""
				i = i + 1
				while i <= #contable and trim(contable[i]) ~= "]]" do
					local trimmedcon = trim(contable[i])
					buffer = buffer .. trimmedcon
					if i < #trimmedcon - 2 then buffer = buffer .. ";" end
					i = i + 1
				end
				target[k] = doveyconf.multilineToTable(trim(buffer))
			elseif v == "[" then
				-- Handle multiline array values ([...])
				local buffer = {}
				i = i + 1
				while i <= #contable and trim(contable[i]) ~= "]" do
					local row = {}
					for value in contable[i]:gmatch("[^,]+") do
						table.insert(row, tovalue(value))
					end
					table.insert(buffer, row)
					i = i + 1
				end
				target[k] = buffer
			else
				-- Handle single-line key-value pairs
				target[k] = tovalue(v)
			end
		end
		i = i + 1
	end
	return file
end

function doveyconf.encode(tbl)
	-- todo: convert tables to ini/toml.
	return tbl or {}
end

return doveyconf
