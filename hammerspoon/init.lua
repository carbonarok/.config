-- ~/.hammerspoon/init.lua

local hyper = { "ctrl", "alt", "cmd" }

-- tmux-style focus between windows in the current space
hs.hotkey.bind(hyper, "h", function()
	hs.eventtap.keyStroke({ "ctrl" }, "left", 0)
end)

hs.hotkey.bind(hyper, "l", function()
	hs.eventtap.keyStroke({ "ctrl" }, "right", 0)
end)

hs.hotkey.bind(hyper, "k", function()
	hs.window.filter.focusNorth()
end)

hs.hotkey.bind(hyper, "j", function()
	hs.window.filter.focusSouth()
end)
