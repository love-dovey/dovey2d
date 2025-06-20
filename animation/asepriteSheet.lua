local AsepriteSheetFormat = {}

function AsepriteSheetFormat.newSheet()
	return {
		frames = {},
		meta = {
			app = "https://github.com/pisayesiwsi/dovey2d",
			version = tostring(Engine.version),
			image = "",
			size = { w = 1, h = 1 },
			scale = "1", -- it's kinda weird how this is a string now that i think about it.
			layers = {
				-- i.e: { name = "string", opacity = number, blendMode = "string" }
			},
			frameTags = {
				-- i.e: { name = "string", from = number, to = number, direction = "string" }
			},
		}
	}
end

function AsepriteSheetFormat.newFrame(image, duration, x, y, w, h, sw, sh, ssx, ssy, ssw, ssh)
	-- should be used only inside another table called frames in the aseprite format
	-- frames = {
	--		newAseFrame(...)
	-- }
	return {
		filename = tostring(image),
		frame = { x = x or 0, y = y or 0, w = w or 1, h = h or 1 },
		spriteSourceSize = { x = ssx or 0, y = ssy or 0, w = ssw or (w or 1), h = ssh or (h or 1), },
		sourceSize = { w = sw or (w or 1), h = sh or (h or 1) },
		duration = duration or 1,
		-- modify these later outside this function if needed.
		rotated = false,
		trimmed = false,
		pivot = { x = 0.5, y = 0.5 }
	}
end

function AsepriteSheetFormat.frameToQuad(frame, width, height)
	return love.graphics.newQuad(
		frame.frame.x, frame.frame.y,
		frame.frame.w, frame.frame.h,
		width, height
	)
end

return AsepriteSheetFormat
