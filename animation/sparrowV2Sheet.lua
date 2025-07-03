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
	assert(texture, "Missing texture for SparrowV2 atlas")
	local frames = {}

	for _, cfg in pairs(attributes) do
		local rotated = cfg.rotated == "true"
		local flipX = cfg.flipX == "true"
		local flipY = cfg.flipY == "true"

		local frameX = tonumber(cfg.frameX) or 0
		local frameY = tonumber(cfg.frameY) or 0
		local frameW = tonumber(cfg.frameWidth) or 1
		local frameH = tonumber(cfg.frameHeight) or 1

		local srcX = tonumber(cfg.x) or 0
		local srcY = tonumber(cfg.y) or 0
		local srcW = tonumber(cfg.width) or 1
		local srcH = tonumber(cfg.height) or 1

		local offsetX, offsetY = frameX, frameY

		if rotated then
			offsetX, offsetY = frameY, -(frameX + srcW)
		end

		local frame = {
			source = { x = srcX, y = srcY, w = srcW, h = srcH },
			offset = {
				x = offsetX,
				y = offsetY,
				w = rotated and frameH or frameW,
				h = rotated and frameW or frameH,
				r = rotated and math.rad(-90) or 0
			},
			scale = { x = flipX and -1 or 1, y = flipY and -1 or 1 }
		}

		table.insert(frames, {
			quad = love.graphics.newQuad(srcX, srcY, srcW, srcH, texture:getDimensions()),
			size = { x = rotated and frameH or frameW, y = rotated and frameW or frameH },
			frameOffset = frame.offset,
			scale = frame.scale,
			texture = texture,
		})
	end
	return frames
end

return SparrowV2Format
