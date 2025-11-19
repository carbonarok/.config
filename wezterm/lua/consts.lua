local wezterm = require("wezterm")
local C = {}

C.BACKGROUND_PATH = wezterm.config_dir .. "/.config/wezterm/assets"
C.IMAGE_PATHS = {
	C.BACKGROUND_PATH .. "/mountains_torres.jpg",
	C.BACKGROUND_PATH .. "/breathtaking_panorama-wallpaper-1366x768.jpg",
	C.BACKGROUND_PATH .. "/peak_nuptse_mountain_nepal_mahalangur_himal_himalayas-wallpaper-1600x900.jpg",
	C.BACKGROUND_PATH .. "/most_beautiful_mountain_ranges_in_the_world-wallpaper-1366x768.jpg",
	C.BACKGROUND_PATH .. "/glacier_lake_mountains_panoramic_view-wallpaper-3840x1600.jpg",
}
return C
