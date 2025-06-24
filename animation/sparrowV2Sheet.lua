local SparrowV2Format = {}

function SparrowV2Format.newSheet()
	return {
		--- <TextureAtlas imagePath="texture.png" width="x" height="y">
		texture = nil, --- @type string
		width = 1, --- @type number
		height = 1, --- @type number
		subTextures = {
			-- newSubTexture("name", number, number, number, number, number, number, number, number, boolean)
		},
	}
end

function SparrowV2Format.newSubTexture(name, x, y, w, h, ox, oy, ow, oh, rotated)
	--- <SubTexture name="name" x="x" y="y" width="w" height="h" frameX="ox" frameY="oy" frameWidth="ow" frameHeight="oh" rotated="true"/>
	-- if rotated == true then rotation = math.deg(-90) end
	return {
		name = name,
		rotation = rotated and math.deg(-90) or 0,
		frame = { x = x or 0, y = y or 0, w = w or 1, h = h or 1 },
		offset = { x = ox or 0, y = oy or 0, w = ow or 1, h = oh or 1 }, -- frameX, frameY, frameWidth, frameHeight
	}
end

function SparrowV2Format.getSubTexturesFromString(content)
	local xmldoc, err = require("dovey.lib.xmlparser").parse(content)
	if err then
		print("Content provided couldn't be parsed, Error(" .. tostring(err) .. ")")
		return {}
	end

	local candidate = 1
	local function getElement()
		--return xmldoc.children[candidate].children
		local element = xmldoc.children[candidate]
		if element.children ~= nil then
			element = xmldoc.children[candidate].children
		else
			while xmldoc.children[candidate].children == nil do
				element = xmldoc.children[candidate]
				candidate = candidate + 1
			end
			element = xmldoc.children[candidate].children
		end
		return element
	end

	local doctable = getElement()
	local animations = {}
	local curPos = 1

	while curPos <= #doctable do
		if doctable[curPos].tag == "SubTexture" then
			local attrs = doctable[curPos].attrs
			local animName = string.sub(attrs.name, 0, #attrs.name - 4)
			if animations[animName] == nil then
				animations[animName] = { frames = {} }
			end
			table.insert(animations[animName].frames, attrs)
		end
		curPos = curPos + 1
	end
	return animations
end

function SparrowV2Format.attributesToQuadList(attributes, texture)
	local frames = {}
	assert(texture,
		"Attempt to build an SparrowAtlas Quad without a texture " ..
		"did you forget to set a texture to an AnimatedSprite?")
	local i = 1
	for k, cfg in pairs(attributes) do
		local trimmed = math.abs(cfg.frameX or 0) > 0
		local rotated = cfg.rotated == "true" or false
		local flipX = cfg.flipX == "true" or false
		local flipY = cfg.flipY == "true" or false
		local frame = {
			source = { x = tonumber(cfg.x) or 0, y = tonumber(cfg.y) or 0, w = tonumber(cfg.width) or 1, h = tonumber(cfg.height) or 1 },
			offset = { x = tonumber(cfg.frameX) or 0, y = tonumber(cfg.frameY) or 0, w = tonumber(cfg.frameWidth) or 1, h = tonumber(cfg.frameHeight) or 1, r = 0 },
			scale = { x = flipX and -1 or 1, y = flipY and -1 or 1 },
		}
		local size = trimmed and frame.offset or frame.source
		if rotated then frame.offset.r = math.rad(-90) end

		local targetWidth = size.w
		local targetHeight = size.h
		if rotated then
			if not trimmed then
				targetWidth = size.h
				targetHeight = size.w
			end
			frame.offset.x = frame.offset.x + (targetWidth - frame.source.w) / 2
			frame.offset.y = frame.offset.y + (targetHeight - frame.source.h) / 2
		end

		frames[#frames + 1] = {
			quad = love.graphics.newQuad(
				frame.source.x, frame.source.y,
				frame.source.w, frame.source.h,
				texture:getDimensions()),
			size = { targetWidth, targetHeight },
			offset = frame.offset,
			scale = frame.scale,
		}
		i = i + 1
	end
	return frames
end

return SparrowV2Format
