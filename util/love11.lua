-- LÖVE11 COMPATIBILITY LAYER
local isLove11 = love.getVersion() == 11
if not isLove11 then
	-- not running on LÖVE11 so there's no point.
	return
end

if love.graphics then
	function love.graphics.origin()
		love.graphics.reset()
	end
	function love.graphics.newTexture(texture)
		return love.graphics.newImage(texture)
	end
end
