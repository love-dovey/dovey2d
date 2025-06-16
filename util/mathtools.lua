function math.round(x)
	-- WHYYY ISN'T THIS A THING?
	return math.floor(x + 0.5)
end

function math.lerp(a, b, weight)
	-- stolen from Multi Theft Auto
	weight = math.max(0, math.min(1, weight))
	return a + (b - a) * weight -- i think.
end

function math.inverselerp(a, b, weight)
	weight = math.max(0, math.min(1, weight))
	return (weight - a) / (b - a)
end

function math.isnan(n)
	return n ~= n
end
