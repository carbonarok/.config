local function tmux_get_target_pane(title)
  local in_session = os.getenv('TMUX')
  if in_session == nil then
    vim.notify('Not inside a tmux session', vim.log.levels.WARN)
    return nil
  end
  -- current session name
  local session = vim.fn.systemlist({ 'tmux', 'display-message', '-p', '#S' })[1]
  if not session or session == '' then
    return vim.notify('Not inside a tmux session', vim.log.levels.WARN)
  end

  -- list panes from ALL sessions (-a), but filter to *this* session
  local res = vim.fn.systemlist({
    'tmux',
    'list-panes',
    '-a',
    '-F',
    '#{pane_id}::#{pane_title}',
    '-f',
    string.format('#{==:#{session_name},%s}', session),
  })

  local target = nil
  for _, line in ipairs(res) do
    local id, t = line:match('^(%%[%d]+)::(.*)$')
    if id and t and t:lower():find(title:lower(), 1, true) then
      target = id
      break
    end
  end

  if not target then
    return vim.notify(string.format("No tmux pane titled '%s' in session '%s'", title, session), vim.log.levels.WARN)
  end

  return target
end

local function tmux_stop_by_title(title)
  local target = tmux_get_target_pane(title)
  if not target then
    return
  end
  vim.fn.jobstart({ 'tmux', 'send-keys', '-t', target, 'C-c', 'Enter' }, { detach = true })
  vim.notify(string.format('Stopped %s', title), vim.log.levels.INFO)
end

local function tmux_restart_by_title(title)
  local target = tmux_get_target_pane(title)
  if not target then
    return
  end
  vim.fn.jobstart({ 'tmux', 'send-keys', '-t', target, 'C-c', 'Up', 'Enter' }, { detach = true })
  vim.notify(string.format('Restarted %s', title), vim.log.levels.INFO)
end

local function tmux_get_target_window(title)
  local in_session = os.getenv('TMUX')
  if in_session == nil then
    vim.notify('Not inside a tmux session', vim.log.levels.WARN)
    return nil
  end

  local session = vim.fn.systemlist({ 'tmux', 'display-message', '-p', '#S' })[1]
  if not session or session == '' then
    return vim.notify('Not inside a tmux session', vim.log.levels.WARN)
  end

  local res = vim.fn.systemlist({
    'tmux',
    'list-windows',
    '-F',
    '#{window_id}::#{window_name}',
    '-f',
    string.format('#{==:#{session_name},%s}', session),
  })

  local target = nil
  for _, line in ipairs(res) do
    local id, t = line:match('^(.*)::(.*)$')
    print(line, id, t)
    if id and t and t:lower():find(title:lower(), 1, true) then
      target = id
      break
    end
  end
  return target
end

local function tmux_join_pane_to_window(window_name, pane_title)
  local window_id = tmux_get_target_window(window_name)
  if not window_id then
    return vim.notify(string.format('No tmux window titled %s', window_name), vim.log.levels.WARN)
  end
  local pane_id = tmux_get_target_pane(pane_title)
  if not pane_id then
    return vim.notify(string.format('No tmux pane titled %s', pane_title), vim.log.levels.WARN)
  end
  vim.notify(string.format('Joining %s to %s', pane_id, window_id), vim.log.levels.INFO)
  vim.fn.jobstart({ 'tmux', 'join-pane', '-t', window_id, '-s', pane_id, '-v' }, { detach = true })
end

--- Keymaps ---
vim.keymap.set('n', '<leader>tsw', function()
  tmux_stop_by_title('worker')
end, { desc = 'Stop worker in current tmux session (all windows)' })

vim.keymap.set('n', '<leader>tsb', function()
  tmux_stop_by_title('backend')
end, { desc = 'Stop backend in current tmux session (all windows)' })

vim.keymap.set('n', '<leader>tsf', function()
  tmux_stop_by_title('frontend')
end, { desc = 'Stop frontend in current tmux session (all windows)' })

vim.keymap.set('n', '<leader>trw', function()
  tmux_restart_by_title('worker')
end, { desc = 'Restart worker in current tmux session (all windows)' })

vim.keymap.set('n', '<leader>trb', function()
  tmux_restart_by_title('backend')
end, { desc = 'Restart backend in current tmux session (all windows)' })

vim.keymap.set('n', '<leader>trf', function()
  tmux_restart_by_title('frontend')
end, { desc = 'Restart frontend in current tmux session (all windows)' })

vim.keymap.set('n', '<leader>tri', function()
  vim.ui.input({ prompt = 'Enter pane title: ' }, function(input)
    if not input or input == '' then
      return vim.notify('Cancelled', vim.log.levels.INFO)
    end
    tmux_restart_by_title(input)
  end)
end, { desc = 'Prompt via UI input' })

vim.keymap.set('n', '<leader>tjp', function()
  vim.ui.input({ prompt = 'Enter pane title: ' }, function(pane_title)
    if not pane_title or pane_title == '' then
      return vim.notify('Cancelled', vim.log.levels.INFO)
    end
    vim.ui.input({ prompt = 'Enter window title: ' }, function(window_name)
      if not window_name or window_name == '' then
        return vim.notify('Cancelled', vim.log.levels.INFO)
      end
      tmux_join_pane_to_window(window_name, pane_title)
    end)
  end)
end, { desc = 'Prompt via UI input' })

vim.keymap.set('n', '<leader>tjb', function()
  local window_name = 'editor'
  local pane_title = 'backend'
  tmux_join_pane_to_window(window_name, pane_title)
end, { desc = 'Join backend to editor' })

vim.keymap.set('n', '<leader>tjf', function()
  local window_name = 'editor'
  local pane_title = 'frontend'
  tmux_join_pane_to_window(window_name, pane_title)
end, { desc = 'Join frontend to editor' })

vim.keymap.set('n', '<leader>tjw', function()
  local window_name = 'editor'
  local pane_title = 'worker'
  tmux_join_pane_to_window(window_name, pane_title)
end, { desc = 'Join worker to editor' })
