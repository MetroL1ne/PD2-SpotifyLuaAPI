-- You can Delete this file, and uses RichPresence.lua by Yourself

--- @func:WinPlatformManager:get_Spotify_state_text()
-- Get Spotify NowPlaying

--- @func:WinPlatformManager:get_NetEase_state_text()
-- Get NetEase NowPlaying

if RequiredScript == "lib/managers/platformmanager" then
	core:module("PlatformManager")

	local RPM = RichPresenceMusical
	local RPMs = RichPresenceMusical.settings

	local old_WPM_set_rich_presence = WinPlatformManager.set_rich_presence
	function WinPlatformManager:set_rich_presence(key, ...)	
		old_WPM_set_rich_presence(self, key or self._current_rich_presence, ...)

		if RPM.Spotify and RPM.Spotify.NetEase_NowPlaying() ~= "ERROR_WINDOW" then
			local state_text = self:get_NetEase_state_text()

			Steam:set_rich_presence("steam_display", "#raw_status")
			Steam:set_rich_presence("status", state_text)
		elseif RPM.Spotify and RPM.Spotify.Spotify_NowPlaying() ~= "ERROR_WINDOW" then
			local state_text =  self:get_Spotify_state_text()
			
			Steam:set_rich_presence("steam_display", "#raw_status")
			Steam:set_rich_presence("status", state_text)
		elseif not key then
			self:set_rich_presence_state(self._current_rich_presence)
		end
	end

	-- local old_WPM_build_status_string = WinPlatformManager.build_status_string
	-- function WinPlatformManager:build_status_string(...)
	-- 	if RPM.Spotify and RPM.Spotify.NetEase_NowPlaying() ~= "ERROR_WINDOW" then
	-- 		return self:get_NetEase_state_text()
	-- 	elseif RPM.Spotify and RPM.Spotify.Spotify_NowPlaying() ~= "ERROR_WINDOW" then
	-- 		return self:get_Spotify_state_text()
	-- 	else
	-- 		return old_WPM_build_status_string(self, ...)
	-- 	end
	-- end
elseif RequiredScript == "lib/managers/skirmishmanager" then
end