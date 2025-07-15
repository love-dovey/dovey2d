local Sound = {
	_playedSources = {
		--[[
		format = {
			looped: (startPoint >= 0.0),
			source: love.Stream,
			startPoint: number,
			loopPoint: number,
		}]]
	},
	_sourceCache = {},
}

--- Function to play standalone, short sounds, not recommended for music.
---
--- You *preferably* would wanna pass plain sources instead of strings here if you wanna avoid caching.
--- @param src string|love.Stream
--- @param volume? number 			How quiet/loud should the volume of the sound be.
--- @param startPoint? number 		How many seconds ahead of time should the audio be started at.
--- @param loopPoint? number 		To how many seconds ahead of time should the audio loop to.
function Sound.playSound(src, volume, startPoint, loopPoint)
	if type(startPoint) ~= "number" or startPoint < 0.0 then
		startPoint = 0.0
	end
	if type(loopPoint) ~= "number" or loopPoint < 0.0 then
		loopPoint = -1
	end

	local pass = true
	local audioSrc = src
	if type(src) == "string" then
		if self._sourceCache[src] == nil then
			self._sourceCache[src] = love.graphics.newSource(src, "static")
		end
		audioSrc = self._sourceCache[src]
	end

	if audioSrc.type and audioSrc:type(audioSrc) == "Source" then
		pass = true
	end

	if pass then
		audioSrc:setVolume(volume or 1.0)
		table.insert(Sound._playedSources, {
			looped = loopPoint >= 0.0,
			startPoint = startPoint or 0.0,
			startVolume = volume or 1.0,
			source = audioSrc:clone(),
			loopPoint = loopPoint,
		})
		Sound._playedSources[#Sound._playedSources].source:play()
	end
end

function Sound.getPlayingSoundCount()
	return #Sound._playedSources
end

function Sound.update(_)
	for _, data in pairs(Sound._playedSources) do
		local source = data.source
		if not source then
			-- source is nil, remove it
			table.remove(Sound._playedSources, source)
			return
		end
		-- TODO: check if it started as playing in the first place
		if not source:isPlaying() then
			if data.loop then
				source:seek(data.startPoint)
				source:play()
			else
				-- call event here when possible, Signal maybe.
				-- Sound.sourceFinished:emit(source, data)
				if source and source.release then source:release() end
				table.remove(Sound._playedSources, _)
			end
		end
	end
end

--Sound = table.freeze(Sound)

return Sound
