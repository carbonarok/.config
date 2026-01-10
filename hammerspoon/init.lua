local hyper = { "ctrl", "alt", "cmd" }

hs.hotkey.bind(hyper, "h", function()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end
	local next_window = win:windowsToWest()[1]

	if next_window then
		next_window:focus()
	else
		local space = hs.spaces.focusedSpace()
		local all_spaces = hs.spaces.spacesForScreen()
		local index = hs.fnutils.indexOf(all_spaces, space)

		if index and index < #all_spaces then
			hs.spaces.gotoSpace(all_spaces[index + 1])
		end
	end
end)

hs.hotkey.bind(hyper, "l", function()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end
	local next_window = win:windowsToEast()[1]

	if next_window then
		next_window:focus()
	else
		local space = hs.spaces.focusedSpace()
		local all_spaces = hs.spaces.spacesForScreen()
		local index = hs.fnutils.indexOf(all_spaces, space)

		if index and index < #all_spaces then
			hs.spaces.gotoSpace(all_spaces[index + 1])
		end
	end
end)

hs.hotkey.bind(hyper, "k", function()
	hs.window.filter.focusNorth()
end)

hs.hotkey.bind(hyper, "j", function()
	hs.window.filter.focusSouth()
end)

-- Close window
hs.hotkey.bind(hyper, "w", function()
	hs.window.focusedWindow():close()
end)

-- Close window
hs.hotkey.bind(hyper, "q", function()
	hs.window.focusedWindow():close()
end)

-- Fullscreen
hs.hotkey.bind(hyper, "f", function()
	hs.window.focusedWindow():toggleFullScreen()
end)

-- Maximize
hs.hotkey.bind(hyper, "m", function()
	hs.window.focusedWindow():maximize()
end)

-- Minimize
hs.hotkey.bind(hyper, "n", function()
	hs.window.focusedWindow():minimize()
end)
