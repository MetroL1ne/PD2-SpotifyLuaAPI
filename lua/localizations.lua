Hooks:Add("LocalizationManagerPostInit", "MenuManagerInitialize_RichPresenceMusical", function(loc)
	rpm_languageList = {
		"loc/english.txt"
	}
	rpm_languagePath = rpm_languageList[1]
	loc:load_localization_file(RichPresenceMusical.path .. rpm_languagePath)
end)
