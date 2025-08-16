core:module("PlatformManager")

local RPM = RichPresenceMusical
local RPMs = RichPresenceMusical.settings

function WinPlatformManager:RPM_NowPlaying()
	local win_list = {
		self:get_NetEase_state_text(),
		self:get_Spotify_state_text()
	}

	for _, text in ipairs(win_list) do
		if text ~= "" then
			return text
		end
	end

	return ""
end

-- 返回网易云音乐正在播放的音乐
function WinPlatformManager:get_NetEase_state_text()
	-- [[ 这里为其他地方调用做兼容，如果检测不到音乐就返回空的字符 ]] --
	-- 可以用于与其他状态mod的文本连接
	-- [[ -------------------------------------------- ]] --

	if not RPM.Spotify then
		return ""
	end

	if RPM.Spotify.NetEase_NowPlaying() == "ERROR_WINDOW" then
		return ""
	end

	-- [[ -------------------------------------------- ]] --

	local strlong_music_info = RPM.Spotify.NetEase_NowPlaying()

	local music_info = string.split(strlong_music_info, "-")

	if not music_info[1] or not music_info[2] then
		return strlong_music_info
	end

	-- 获取歌名和歌手并去除首尾的空字符
	local sound_name = RPMs.rpm_display_sound_name and string.gsub(music_info[1], "^%s*(.-)%s*$", "%1") or ""
	local sound_author = RPMs.rpm_display_sound_author and string.gsub(music_info[2], "^%s*(.-)%s*$", "%1") or ""

	local sound_info_1 = sound_name
	local sound_info_2 = sound_author

	-- 检测是否互换歌名和歌手的排序方式
	if RPMs.rpm_sort_mode == 2 then
		sound_info_1 = sound_author
		sound_info_2 = sound_name
	end

	local Left = RPMs.rpm_left_text
	local Right = RPMs.rpm_right_text
	local Middle = RPMs.rpm_middle_text
	
	local state_text = Left .. sound_info_1 .. Middle .. sound_info_2 .. Right

	return state_text
end

-- 返回Spotify正在播放的音乐
function WinPlatformManager:get_Spotify_state_text()
	-- [[ 这里为其他地方调用做兼容，如果检测不到音乐就返回空的字符 ]] --
	-- 可以用于与其他状态mod的文本连接
	-- [[ -------------------------------------------- ]] --

	if not RPM.Spotify then
		return ""
	end

	if RPM.Spotify.Spotify_NowPlaying() == "ERROR_WINDOW" then
		return ""
	end

	-- [[ -------------------------------------------- ]] --

	local strlong_music_info = RPM.Spotify.Spotify_NowPlaying()

	local music_info = string.split(strlong_music_info, "-")

	if not music_info[1] or not music_info[2] then
		return strlong_music_info
	end

	-- 获取歌名和歌手并去除首尾的空字符
	local sound_name = RPMs.rpm_display_sound_name and string.gsub(music_info[2], "^%s*(.-)%s*$", "%1") or ""
	local sound_author = RPMs.rpm_display_sound_author and string.gsub(music_info[1], "^%s*(.-)%s*$", "%1") or ""

	local sound_info_1 = sound_name
	local sound_info_2 = sound_author

	-- 检测是否互换歌名和歌手的排序方式
	if RPMs.rpm_sort_mode == 2 then
		sound_info_1 = sound_author
		sound_info_2 = sound_name
	end

	local Left = RPMs.rpm_left_text
	local Right = RPMs.rpm_right_text
	local Middle = RPMs.rpm_middle_text

	local state_text = Left .. sound_info_1 .. Middle .. sound_info_2 .. Right

	return state_text
end

-- 用于实时刷新当前播放的音乐和Steam状态
Hooks:PostHook(GenericPlatformManager, "update", "rpm_update_set_rich_presence", function(self, t, dt)
	if self._current_rich_presence ~= "Idle" and not managers.network:session() then
		return
	end

	self._rpm_music_presence_timer = self._rpm_music_presence_timer or 0
	self._rpm_music_presence_timer = self._rpm_music_presence_timer + dt
	
	if self._rpm_music_presence_timer >= 3 then
		self._rpm_music_presence_timer = 0
		self:set_rich_presence()
	end		
end)