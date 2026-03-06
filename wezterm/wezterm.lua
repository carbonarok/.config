local wezterm = require("wezterm")
local C = require("lua/consts")

local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.disable_default_key_bindings = true

local function is_nvim(pane)
	local p = pane:get_foreground_process_name() or ""
	return p:find("nvim") ~= nil or p:find("vim") ~= nil
end

local function smart_cmd(key, arrow)
	return wezterm.action_callback(function(win, pane)
		if is_nvim(pane) then
			-- Your nvim “CMD as Meta” setup expects <M-h/j/k/l>
			win:perform_action(wezterm.action.SendKey({ key = key, mods = "ALT" }), pane)
		else
			-- Normal terminal: real arrows
			win:perform_action(wezterm.action.SendKey({ key = arrow }), pane)
		end
	end)
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

config.colors = {
	tab_bar = {
		background = "none",
	},
}

------------------------------------------------------------
-- GENERAL BEHAVIOUR
------------------------------------------------------------
config.scrollback_lines = 10000
config.adjust_window_size_when_changing_font_size = false
config.window_background_opacity = 1
config.text_background_opacity = 1.0

config.macos_window_background_blur = 20
config.window_padding = {
	top = 0,
	right = 0,
	bottom = 0,
	left = 0,
}

config.max_fps = 120
config.prefer_egl = true

------------------------------------------------------------
-- CMD → ALT (META) MAPPINGS
-- CMD + key -> send ALT + key (for Neovim <M-…> mappings)
-- We *only* do this for a–z, A–Z to avoid weirdness with punctuation.
------------------------------------------------------------
local function cmd_meta_mappings()
	local mappings = {}

	-- Keys where we DON'T want CMD to be turned into ALT
	-- (we reserve these for WezTerm actions)
	local reserved = {
		c = true, -- copy
		v = true, -- paste
		t = true, -- new tab
		x = true, -- close tab
		f = true, -- search
		h = true, -- smart navigation
		j = true, -- smart navigation
		k = true, -- smart navigation
		l = true, -- smart navigation
		["0"] = true, -- reset font
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
		key = "x",
		mods = "CMD",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},
	-- Copy text
	{
		key = "c",
		mods = "CMD",
		action = wezterm.action.CopyTo("Clipboard"),
	},
	-- Paste text
	{
		key = "v",
		mods = "CMD",
		action = wezterm.action.PasteFrom("Clipboard"),
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
	{
		key = "=",
		mods = "CMD",
		action = wezterm.action.IncreaseFontSize,
	},
	{
		key = "-",
		mods = "CMD",
		action = wezterm.action.DecreaseFontSize,
	},
	-- Reset font size
	{
		key = "0",
		mods = "CMD",
		action = wezterm.action.ResetFontSize,
	},
	-- Quick reload config
	{
		key = "r",
		mods = "CMD|SHIFT",
		action = wezterm.action.ReloadConfiguration,
	},
	-- Search scrollback (CMD+f)
	{
		key = "f",
		mods = "CMD",
		action = wezterm.action.Search({ CaseInSensitiveString = "" }),
	},
	-- Quick select mode (URLs, paths, etc.)
	{
		key = "u",
		mods = "CMD|SHIFT",
		action = wezterm.action.QuickSelect,
	},
	-- Open URL under cursor
	{
		key = "o",
		mods = "CMD|SHIFT",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
	{
		key = "h",
		mods = "CMD",
		action = smart_cmd("h", "LeftArrow"),
	},
	{
		key = "j",
		mods = "CMD",
		action = smart_cmd("j", "DownArrow"),
	},
	{
		key = "k",
		mods = "CMD",
		action = smart_cmd("k", "UpArrow"),
	},
	{
		key = "l",
		mods = "CMD",
		action = smart_cmd("l", "RightArrow"),
	},
	{
		key = ";",
		mods = "CMD",
		action = wezterm.action.SendKey({ key = "Enter" }),
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
config.leader = { key = "0", mods = "CTRL" }

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

	-- Name Tab
	{
		key = "n",
		mods = "LEADER",
		action = wezterm.action.PromptInputLine({
			description = "Enter new name for tab:",
			action = wezterm.action_callback(function(window, pane, line)
				window:active_tab():set_title(line)
			end),
		}),
	},

	-- Panes: split
	{
		key = "-",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "\\",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
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
	-- Open command palette
	{
		key = "p",
		mods = "LEADER",
		action = wezterm.action.ActivateCommandPalette,
	},

	-- Pane: zoom/maximize toggle
	{
		key = "z",
		mods = "LEADER",
		action = wezterm.action.TogglePaneZoomState,
	},

	-- Pane: close current pane
	{
		key = "q",
		mods = "LEADER",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},

	-- Pane: rotate panes
	{
		key = "Space",
		mods = "LEADER",
		action = wezterm.action.RotatePanes("Clockwise"),
	},

	-- Copy mode (vim-like scrollback navigation)
	{
		key = "[",
		mods = "LEADER",
		action = wezterm.action.ActivateCopyMode,
	},

	-- Move tab left/right
	{
		key = "<",
		mods = "LEADER|SHIFT",
		action = wezterm.action.MoveTabRelative(-1),
	},
	{
		key = ">",
		mods = "LEADER|SHIFT",
		action = wezterm.action.MoveTabRelative(1),
	},

	-- Show tab navigator
	{
		key = "w",
		mods = "LEADER",
		action = wezterm.action.ShowTabNavigator,
	},

	-- Show launcher menu
	{
		key = "l",
		mods = "LEADER|SHIFT",
		action = wezterm.action.ShowLauncher,
	},
}

for _, mapping in ipairs(leader_keys) do
	table.insert(config.keys, mapping)
end

------------------------------------------------------------
-- ALT BEHAVIOUR
-- IMPORTANT: Set to false so ALT sends proper escape sequences
-- that Neovim recognizes as <M-...> mappings
------------------------------------------------------------
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = false

config.native_macos_fullscreen_mode = true

------------------------------------------------------------
-- ADDITIONAL SETTINGS
------------------------------------------------------------
-- Cursor
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- Quick select patterns (for CMD+SHIFT+U)
config.quick_select_patterns = {
	-- Match file paths
	"[\\w\\-\\./]+\\.[\\w]+",
	-- Match URLs
	"https?://[\\w\\-\\./]+",
	-- Match git commit hashes
	"[0-9a-f]{7,40}",
	-- Match UUIDs
	"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
}

-- Hyperlink rules (clickable links)
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Add custom rule for file paths
table.insert(config.hyperlink_rules, {
	regex = "[./~][\\w\\-\\./]+",
	format = "file://$0",
})

-- Inactive pane dimming
config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.7,
}

-- Window decorations
-- config.window_decorations = "RESIZE"

-- Tab bar styling
config.tab_bar_at_bottom = false
config.tab_max_width = 32

-- Add custom commands
local commands = require("commands.init")

wezterm.on("augment-command-palette", function(window, pane)
	return commands
end)

local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	math.randomseed(os.time())
	local random_image = C.IMAGE_PATHS[math.random(#C.IMAGE_PATHS)]

	window:gui_window():set_config_overrides({
		window_background_image = random_image,
		window_background_image_hsb = {
			brightness = 0.04,
			hue = 1.0,
			saturation = 1.0,
		},
	})
end)

return config
