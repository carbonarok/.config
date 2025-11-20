local wezterm = require("wezterm")
local C = require("lua/consts")

local command = {
	brief = "Toggle background",
	icon = "md_image",
	action = wezterm.action_callback(function(window, pane)
		local overrides = window:get_config_overrides() or {}

		-- If no background image is set → enable one
		if not overrides.window_background_image then
			overrides.window_background_image = C.IMAGE_PATHS[math.random(#C.IMAGE_PATHS)]

			-- Optional: dim the image when enabled
			overrides.window_background_image_hsb = {
				brightness = 0.06,
				hue = 1.0,
				saturation = 1.0,
			}
		else
			-- Image is active → disable it and return to base theme
			overrides.window_background_image = nil
			overrides.window_background_image_hsb = nil
			overrides.text_background_opacity = nil
			overrides.window_background_opacity = nil
		end

		window:set_config_overrides(overrides)
	end),
}

return command
