-- ~/.hammerspoon/init.lua

local hyper = { "ctrl", "alt", "cmd" }

local spaces = require("hs.spaces")
local fnutils = hs.fnutils

-- Helper: get spaces for the screen of the current window (or main screen)
local function spacesForCurrentScreen(win)
	local screen = win and win:screen() or hs.screen.mainScreen()
	return spaces.spacesForScreen(screen)
end

-- Helper: move focus in a direction; if no window in that direction,
-- for west/east move to previous/next space
local function focusWindowOrSpace(direction)
	local win = hs.window.focusedWindow()
	local next_window = nil

	if win then
		if direction == "west" then
			next_window = win:windowsToWest()[1]
		elseif direction == "east" then
			next_window = win:windowsToEast()[1]
		elseif direction == "north" then
			next_window = win:windowsToNorth()[1]
		elseif direction == "south" then
			next_window = win:windowsToSouth()[1]
		end
	end

	-- If there is a window in that direction, just focus it
	if next_window then
		next_window:focus()
		return
	end

	-- If no window and direction is horizontal, move spaces
	if direction == "west" or direction == "east" then
		local current_space = spaces.focusedSpace()
		local all_spaces = spacesForCurrentScreen(win)
		local index = fnutils.indexOf(all_spaces, current_space)

		if not index then
			return
		end

		if direction == "west" and index > 1 then
			spaces.gotoSpace(all_spaces[index - 1])
		elseif direction == "east" and index < #all_spaces then
			spaces.gotoSpace(all_spaces[index + 1])
		end
	end
end

-- Directional focus / space movement
hs.hotkey.bind(hyper, "h", function()
	focusWindowOrSpace("west")
end)

hs.hotkey.bind(hyper, "l", function()
	focusWindowOrSpace("east")
end)

hs.hotkey.bind(hyper, "k", function()
	focusWindowOrSpace("north")
end)

hs.hotkey.bind(hyper, "j", function()
	focusWindowOrSpace("south")
end)

-- Helper: safely act on focused window
local function withFocusedWindow(fn)
	local win = hs.window.focusedWindow()
	if win then
		fn(win)
	end
end

-- Close window (w and q)
local function closeFocused()
	withFocusedWindow(function(win)
		win:close()
	end)
end

hs.hotkey.bind(hyper, "w", closeFocused)
hs.hotkey.bind(hyper, "q", closeFocused)

-- Fullscreen
hs.hotkey.bind(hyper, "f", function()
	withFocusedWindow(function(win)
		win:toggleFullScreen()
	end)
end)

-- Maximize
hs.hotkey.bind(hyper, "m", function()
	withFocusedWindow(function(win)
		win:maximize()
	end)
end)

-- Minimize
hs.hotkey.bind(hyper, "n", function()
	withFocusedWindow(function(win)
		win:minimize()
	end)
end)
