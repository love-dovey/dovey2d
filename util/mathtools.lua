--- Checks if a number isn't a number.
--- @param n number 		Number to check
--- @return boolean
function math.isnan(n)
	return n ~= n
end

--- Checks if `n` is too big (positively or negatively).
--- @param n number
--- @return boolean
function math.ishuge(n)
	return n == math.huge or n == -math.huge
end

--- Clamps `n` to be within the provided range.
--- @param n number 				Number to clamp.
--- @param min number 				Lowest reachable number.
--- @param max number 				Highest reachable number.
--- @return number
function math.clamp(n, min, max)
	return math.min(math.max(n, min), max)
end

--- Wraps `n` within the provided range.
---
--- If `n` is lower than `min`, it wraps around to `max`, and vice-versa.
--- @param n number 				Number to wrap.
--- @param min number 				Lower bound.
--- @param max number 				Upper bound.
--- @param step? number|nil			Snap interval for numbers (keep unset for normal wrapping).
--- @return number
function math.wrap(n, min, max, step)
	step = step or 1
	local r = max - min
	local offset = ((n - min) % r + r) % r
	return math.snap(offset, step) + min
end

--- Snaps `n` to the nearest multiple of `x`
--- @param n number 		Number to snap.
--- @param x number 		Snap interval.
--- @return number
function math.snap(n, x)
	x = x or 1
	return math.floor(n / x + 0.5) * x
end

--- Rounds `n` to its nearest whole number.
--- @param n number 		Number to round.
--- @return number
function math.round(n)
	-- I'm asking politely, why isn't this built-in
	-- update: IT IS IN NEWER LUA????
	return math.floor(n + 0.5)
end

--- Remaps `n` from range (ia, ib) to range (oa, ob).
--- @param n number 		Number to remap.
--- @param ia number 		Original range start.
--- @param ib number 		Original range end.
--- @param oa number 		New range start.
--- @param ob number 		New range end.
--- @return number
function math.remap(n, ia, ib, oa, ob)
	if ia == ib then return oa end -- division by zero, avoid.
	local mult = (n - ia) / (ib - ia)
	return oa + (ob - oa) * mult
end

--- Interpolates between `a` and `b`, `x` represents a percentage (from 0 to 1).
---
--- If `x` is 0, the result will be `a`, if `x` is 1, the result will be `b`, simple.
---
--- `x` is clamped between 0 and 1, cannot be greater or lesser, unless `breakclamp` is true.
--- @param a number 				Value to move.
--- @param b number 				Target value.
--- @param x number 				Percentage.
--- @param breakclamp boolean 		Prevents `x` from being clamped.
--- @return number
function math.lerp(a, b, x, breakclamp)
	breakclamp = breakclamp or false
	-- Multi Theft Auto sends regards
	if not breakclamp then
		x = math.clamp(x, 0, 1)
	end
	return a + (b - a) * x
end

--- Calculates how far `x` is between `a` and `b`.
---
--- If `x` is equal to `a`, the result will be 0, if `x` is equal to `b`, the result will be 1.
---
--- `x` is clamped between 0 and 1, cannot be greater or lesser, unless `breakclamp` is true.
--- @param a number 				Value to move.
--- @param b number 				Target value.
--- @param x number 				Percentage.
--- @param breakclamp boolean 		Prevents `x` from being clamped.
--- @return number
function math.inverselerp(a, b, x, breakclamp)
	if a == b then return 0 end -- division by zero, let's... let's not.
	breakclamp = breakclamp or false
	if not breakclamp then
		x = math.clamp(x, math.min(a, b), math.max(a, b))
	end
	return (x - a) / (b - a)
end

--- Returns the sign of `n`
--- @param n number
--- @return number
function math.sign(n)
	-- i wrote `sigh` by accident more times than I would like to admit.
	return n > 0 and 1 or n < 0 and -1 or 0
end

-- from Rect2.lua, you wouldn't believe me if i told you these functions are genuinely super useful.
-- these are mainly useful here because Rectangles shouldn't be the only thing that can use them (*personally...*)

--- Returns the center point of all the provided values.
--- @param x number 		X position
--- @param y number 		Y position
--- @param w number 		Width
--- @param h number 		Height
--- @return number, number
function math.center(x, y, w, h)
	return (x + w * 0.5), (y + h * 0.5)
end

--- Returns the area between two values.
--- @param x number 		Width
--- @param y number 		Height
--- @return number
function math.area(x, y)
	return x * y
end

--- Returns true if two areas overlap.
--- @param x number 	X position of Area A
--- @param tx number 	X position of Area B
--- @param y number 	Y position of Area A
--- @param ty number 	Y position of Area B
--- @param w number 	Width of Area A
--- @param tw number 	Width of Area B
--- @param h number 	Height of Area A
--- @param th number 	Height of Area B
--- @return boolean
function math.overlaps(x, tx, y, ty, w, tw, h, th)
	return x < tx + tw and x + w > tx and y < ty + th and y + h > ty
end
