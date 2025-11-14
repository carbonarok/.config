local wezterm = require("wezterm")

local config = {}

-- Helper to generate CMD→ALT mappings
local function cmd_meta_mappings()
	local mappings = {}

	-- All the keys you want CMD to act as META for
	local keys = {}

	-- a-z
	for i = string.byte("a"), string.byte("z") do
		table.insert(keys, string.char(i))
	end

	-- A-Z (optional, comment out if you don't want these)
	for i = string.byte("A"), string.byte("Z") do
		table.insert(keys, string.char(i))
	end

	-- Numbers
	for i = 0, 9 do
		table.insert(keys, tostring(i))
	end

	-- Common punctuation / symbols
	local extra = {
		".",
		",",
		";",
		"'",
		'"',
		"/",
		"\\",
		"-",
		"=",
		"[",
		"]",
		"`",
		" ", -- space
	}
	for _, k in ipairs(extra) do
		table.insert(keys, k)
	end

	-- Build the mappings: CMD+<key> → ALT+<key>
	for _, k in ipairs(keys) do
		table.insert(mappings, {
			key = k,
			mods = "CMD",
			action = wezterm.action.SendKey({ key = k, mods = "ALT" }),
		})
	end

	return mappings
end

config.keys = cmd_meta_mappings()

-- Recommended so Alt still behaves like Meta where needed
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

return config
