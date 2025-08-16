_G.RichPresenceMusical = _G.RichPresenceMusical or {}

RichPresenceMusical.path = ModPath
RichPresenceMusical.data_path = SavePath .. "RichPresenceMusical.txt"

RichPresenceMusical.settings = {
	rpm_sort_mode = 1,
	rpm_left_text = "♬ Playing : ",
	rpm_right_text = " ♬",
	rpm_middle_text = " - ",
	rpm_display_sound_name = true,
	rpm_display_sound_author = true
}

_, RichPresenceMusical.Spotify = blt.load_native(ModPath .. "SpotifyLuaAPI.dll")

function RichPresenceMusical:Save()
	local file = io.open(self.data_path, "w+")
	if file then
		file:write(json.encode(self.settings) .. "\n")
		file:close()
	end
end

function RichPresenceMusical:Load()
	local file = io.open(self.data_path, "r")
	if file then
		local options = json.decode(file:read("*all"))

		if not options then
			return
		end
		
		for num, option in pairs(options) do
			self.settings[num] = option
		end
		file:close()
	end
end

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_RichPresenceMusical", function(menu_manager)
	MenuCallbackHandler.RichPresenceMusical_SetValueCallback = function(this, item)
		RichPresenceMusical.settings[item:name()] = item:value()
	end

	MenuCallbackHandler.RichPresenceMusical_SetToggleCallback = function(this, item)
		RichPresenceMusical.settings[item:name()] = item:value() == "on"
	end

	MenuCallbackHandler.RichPresenceMusical_Save = function(this, item)
		RichPresenceMusical:Save()
	end
	
	MenuHelper:LoadFromJsonFile(RichPresenceMusical.path .. "menu/options.txt", RichPresenceMusical, RichPresenceMusical.settings)
	
	RichPresenceMusical:Load()
end)