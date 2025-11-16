local wezterm = require("wezterm")

local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

------------------------------------------------------------
-- FONT / UI
------------------------------------------------------------
config.font = wezterm.font_with_fallback({
	"MesloLGS NF",
	"FiraCode Nerd Font",
})
config.font_size = 13.0
config.line_height = 1.1

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.audible_bell = "Disabled"
config.color_scheme = "Solarized Dark Higher Contrast"

------------------------------------------------------------
-- GENERAL BEHAVIOUR
------------------------------------------------------------
config.scrollback_lines = 5000
config.adjust_window_size_when_changing_font_size = false
config.window_background_opacity = 1
config.text_background_opacity = 1.0

local image_paths = {
	"/Users/opti-mac/Documents/Images/mountains_torres.jpg",
	"/Users/opti-mac/Documents/Images/breathtaking_panorama-wallpaper-1366x768.jpg",
	"/Users/opti-mac/Documents/Images/peak_nuptse_mountain_nepal_mahalangur_himal_himalayas-wallpaper-1600x900.jpg",
	"/Users/opti-mac/Documents/Images/most_beautiful_mountain_ranges_in_the_world-wallpaper-1366x768.jpg",
	"/Users/opti-mac/Documents/Images/glacier_lake_mountains_panoramic_view-wallpaper-3840x1600.jpg",
}

math.randomseed(os.time())
local random_image = image_paths[math.random(#image_paths)]
config.window_background_image = random_image

config.window_background_image_hsb = {
	brightness = 0.04,
	hue = 1.0,
	saturation = 1.0,
}
config.macos_window_background_blur = 20

------------------------------------------------------------
-- CMD → ALT (META) MAPPINGS
-- CMD + key -> send ALT + key (for Neovim <M-…> mappings)
-- We *only* do this for a–z, A–Z to avoid weirdness with punctuation.
------------------------------------------------------------
local function cmd_meta_mappings()
	local mappings = {}

	-- Keys where we DON'T want CMD to be turned into ALT
	-- (we reserve these for tab management etc.)
	local reserved = {
		t = true,
		w = true,
		["0"] = true,
		["1"] = true,
		["2"] = true,
		["3"] = true,
		["4"] = true,
		["5"] = true,
		["6"] = true,
		["7"] = true,
		["8"] = true,
		["9"] = true,
	}

	local keys = {}

	-- a-z
	for i = string.byte("a"), string.byte("z") do
		table.insert(keys, string.char(i))
	end

	-- A-Z
	for i = string.byte("A"), string.byte("Z") do
		table.insert(keys, string.char(i))
	end

	for _, k in ipairs(keys) do
		if not reserved[k] then
			table.insert(mappings, {
				key = k,
				mods = "CMD",
				action = wezterm.action.SendKey({ key = k, mods = "ALT" }),
			})
		end
	end

	return mappings
end

-- Start with CMD→ALT mappings
config.keys = cmd_meta_mappings()

------------------------------------------------------------
-- TAB MANAGEMENT (CMD = "Mac-like")
------------------------------------------------------------
local tab_keys = {
	-- New tab
	{
		key = "t",
		mods = "CMD",
		action = wezterm.action.SpawnTab("DefaultDomain"),
	},
	-- Close tab
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},
	-- Next / previous tab
	{
		key = "RightArrow",
		mods = "CMD|SHIFT",
		action = wezterm.action.ActivateTabRelative(1),
	},
	{
		key = "LeftArrow",
		mods = "CMD|SHIFT",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	-- Jump directly to tab N (0–8)
	{ key = "1", mods = "CMD", action = wezterm.action.ActivateTab(0) },
	{ key = "2", mods = "CMD", action = wezterm.action.ActivateTab(1) },
	{ key = "3", mods = "CMD", action = wezterm.action.ActivateTab(2) },
	{ key = "4", mods = "CMD", action = wezterm.action.ActivateTab(3) },
	{ key = "5", mods = "CMD", action = wezterm.action.ActivateTab(4) },
	{ key = "6", mods = "CMD", action = wezterm.action.ActivateTab(5) },
	{ key = "7", mods = "CMD", action = wezterm.action.ActivateTab(6) },
	{ key = "8", mods = "CMD", action = wezterm.action.ActivateTab(7) },
	{ key = "9", mods = "CMD", action = wezterm.action.ActivateTab(8) },

	-- Optional: toggle full screen with CMD+Enter
	{
		key = "Enter",
		mods = "CMD",
		action = wezterm.action.ToggleFullScreen,
	},
}

for _, mapping in ipairs(tab_keys) do
	table.insert(config.keys, mapping)
end

------------------------------------------------------------
-- LEADER KEY (WezTerm "prefix")
-- NOTE: On macOS, make sure CTRL+Space is NOT bound in System Settings
-- (Keyboard Shortcuts), or macOS will eat it before WezTerm sees it.
------------------------------------------------------------
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1500 }

local leader_keys = {
	-- Tabs
	{
		key = "c",
		mods = "LEADER",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "x",
		mods = "LEADER",
		action = wezterm.action.CloseCurrentTab({ confirm = false }),
	},

	-- Panes: split
	{
		key = "-",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "\\",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},

	-- Panes: navigate (Leader + h/j/k/l)
	{
		key = "h",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},

	-- Panes: resize (Leader + SHIFT + h/j/k/l)
	{
		key = "H",
		mods = "LEADER|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Left", 3 }),
	},
	{
		key = "J",
		mods = "LEADER|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Down", 3 }),
	},
	{
		key = "K",
		mods = "LEADER|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Up", 3 }),
	},
	{
		key = "L",
		mods = "LEADER|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Right", 3 }),
	},
}

for _, mapping in ipairs(leader_keys) do
	table.insert(config.keys, mapping)
end

------------------------------------------------------------
-- ALT BEHAVIOUR
-- Leave ALT mostly for Neovim; WezTerm doesn't bind ALT directly now.
------------------------------------------------------------
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

return config
