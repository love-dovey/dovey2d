-- This script handles retrocompatibility with older LÖVE versions.
-- the target version for the Engine is LÖVE12 (unreleased as of 2025-06-14)

if love.getVersion() == 11 then
	-- LÖVE11 COMPATIBILITY LAYER
	if love.graphics then
		function love.graphics.origin()
			love.graphics.reset()
		end
		function love.graphics.newTexture(texture)
			return love.graphics.newImage(texture)
		end
	end
end
