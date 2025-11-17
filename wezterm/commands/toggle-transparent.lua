local wezterm = require("wezterm")

local command = {
	brief = "Toggle transparent background",
	icon = "md_circle_opacity",
	action = wezterm.action_callback(function(window, pane)
		local overrides = window:get_config_overrides() or {}

		if overrides.window_background_opacity == nil or overrides.window_background_opacity == 1 then
			overrides.window_background_opacity = 0.8
		else
			overrides.window_background_opacity = 1
		end

		window:set_config_overrides(overrides)
	end),
}

return command
