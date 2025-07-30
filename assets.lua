local Assets = {	
	textures = {},
	audioSources = {},
	fonts = {},
	refCounts = {}, -- Counts references of initialized C-objects
	metadata = {}, -- To retrieve metadata of initialized C-objects (path, cache key, etc)

	loaders = {
		texture = function(path) return love.graphics.newTexture(path) end,
		sound = function(path) return love.audio.newSource(path, "static") end,
		music = function(path) return love.audio.newSource(path, "stream") end,
		font = function(path, size) return love.graphics.newFont(path, size) end,
	},

	-- TODO: trackers = {...} for mods?

	releasers = {
		texture = function(tex)
			if tex and type(tex) == "userdata" and tex.release then tex:release() end
		end,
		sound = function(snd)
			if snd and type(snd) == "userdata" and snd.release then
				if snd:isPlaying() then snd:stop() end
				snd:release()
			end
		end,
		music = function(str)
			if str and type(str) == "userdata" and str.release then
				if str:isPlaying() then str:stop() end
				str:release()
			end
		end,
		font = function(fnt)
			-- Fonts don't need explicit release.
		end
	}
}

local function _getResourceTable(resType)
	local resTypeSolved = resType
	-- just making sure we get the correct table for audio caching.
	if resType == "music" or resType == "stream" or resType == "audio" or resType == "sound" then
		resTypeSolved = "audioSource"
	end
	return Assets[resTypeSolved .. "s"]
end

-- Internal master loader.
local function _getResource(resType, path, cacheKey, ...)
	local key = cacheKey or path
	local resourceTable = _getResourceTable(resType)

	if resourceTable[key] then
		Assets.refCounts[key] = (Assets.refCounts[key] or 0) + 1
		return resourceTable[key]
	end

	local loader = Assets.loaders[resType]
	if not loader then
		error("Cannot find loader for resource type: " .. resType)
	end
	local resource = loader(path, ...)
	if not resource then
		error("Failed to load resource: " .. path)
	end

	if not resourceTable[key] then
		Assets.refCounts[key] = 1
	else
		Assets.refCounts[key] = Assets.refCounts[key] + 1
	end

	Assets.metadata[resource] = {
		resPath = _path,
		cacheKey = key,
		resType = resType,
		persistent = false,
	}

	Assets.refCounts[key] = 1
	resourceTable[key] = resource
	return resource
end

--- Makes a new texture and caches it.
--- @param path string File path
--- @param cacheKey? string Optional custom cache key
--- @return love.Texture
function Assets.getTexture(path, cacheKey)
	return _getResource("texture", path, cacheKey)
end

--- Makes a new static audio source and caches it.
--- @param path string File path
--- @param cacheKey? string Optional custom cache key
--- @return love.Source
function Assets.getSound(path, cacheKey)
	return _getResource("sound", path, cacheKey)
end

--- Makes a new streamable audio source (for background music) and caches it.
--- @param path string File path
--- @param cacheKey? string Optional custom cache key
--- @return love.Source
function Assets.getMusic(path, cacheKey)
	return _getResource("music", path, cacheKey)
end

--- Makes a new font (with size) and caches it.
--- @param path string File path
--- @param size? number Optional font size
--- @param cacheKey? string Optional custom cache key
function Assets.getFont(path, size, cacheKey)
	local key = cacheKey or (path .. ":" .. tostring(size))
	return _getResource("font", path, key, size)
end

--- Releases a specific resource
--- @param resource userdata The resource to release
function Assets.releaseResource(resource)
	if not resource then return end
	local meta = Assets.metadata[resource]
	if not meta then return end
	local key = meta._cacheKey or meta._resPath
	if not key then return end

	if Assets.refCounts[key] then
		Assets.refCounts[key] = Assets.refCounts[key] - 1

		if Assets.refCounts[key] <= 0 then
			local resType = meta._resType
			local resourceTable = _getResourceTable(resType)
			local releaser = Assets.releasers[resType]
			if releaser and not meta.persistent then
				releaser(resource)
			end
			resourceTable[key] = nil
			Assets.refCounts[key] = nil
			Assets.metadata[resource] = nil
		end
	end
end

--- Releases a resource by its key
--- @param resType string The resource type (texture, sound, etc.)
--- @param cacheKey string The cache key used when loading
function Assets.releaseResourceByKey(resType, cacheKey)
	local resource = _getResourceTable(resType)[cacheKey]
	if resource then Assets.releaseResource(resource) end
end

--- Releases all resources of a specific type
--- @param resType string The resource type to clear
function Assets.clearResourceType(resType)
	local resourceTable = _getResourceTable(resType)
	local releaser = Assets.releasers[resType]
	for key, resource in pairs(resourceTable) do
		if releaser then
			releaser(resource)
		end
		resourceTable[key] = nil
		Assets.refCounts[key] = nil
		Assets.metadata[resource] = nil
	end
end

--- Releases all managed resources
function Assets.clearAll()
	for key, tex in pairs(Assets.textures) do
		Assets.releasers.texture(tex)
		Assets.textures[key] = nil
		Assets.refCounts[key] = nil
		Assets.metadata[tex] = nil
	end
	for key, snd in pairs(Assets.audioSources) do
		Assets.releasers.sound(snd)
		Assets.textures[key] = nil
		Assets.refCounts[key] = nil
		Assets.metadata[snd] = nil
	end
	for key, fnt in pairs(Assets.audioSources) do
		Assets.releasers.font(snd)
		Assets.fonts[key] = nil
		Assets.refCounts[key] = nil
		Assets.metadata[fnt] = nil
	end
end

--- Gets the reference count for a resource
--- @param key string The resource key
--- @return number
function Assets.getRefCount(key) return Assets.refCounts[key] or 0 end

--- Gets the reference count of every single (in-use) resource.
function Assets.getTotalRefCount()
	local counter = 0
	for _, _ in pairs(Assets.refCounts) do
		counter = counter + 1
	end
	return counter
end

return Assets
