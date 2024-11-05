return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`party_finder_menu` encountered an error loading the Darktide Mod Framework.")

		new_mod("party_finder_menu", {
			mod_script       = "party_finder_menu/scripts/mods/party_finder_menu/party_finder_menu",
			mod_data         = "party_finder_menu/scripts/mods/party_finder_menu/party_finder_menu_data",
			mod_localization = "party_finder_menu/scripts/mods/party_finder_menu/party_finder_menu_localization",
		})
	end,
	packages = {},
}
