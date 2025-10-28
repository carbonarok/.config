local function tmux_get_target_pane(title)
  local in_session = os.getenv('TMUX')
  if in_session == nil then
    return vim.notify('Not inside a tmux session', vim.log.levels.WARN)
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
  vim.fn.jobstart({ 'tmux', 'send-keys', '-t', target, 'C-c', 'Enter' }, { detach = true })
  vim.notify(string.format('Stopped %s', title), vim.log.levels.INFO)
end

vim.keymap.set('n', '<leader>tsw', function()
  tmux_stop_by_title('worker')
end, { desc = 'Stop worker in current tmux session (all windows)' })

vim.keymap.set('n', '<leader>tsb', function()
  tmux_stop_by_title('backend')
end, { desc = 'Stop backend in current tmux session (all windows)' })

vim.keymap.set('n', '<leader>tsf', function()
  tmux_stop_by_title('frontend')
end, { desc = 'Stop frontend in current tmux session (all windows)' })

local function tmux_restart_by_title(title)
  local target = tmux_get_target_pane(title)
  vim.fn.jobstart({ 'tmux', 'send-keys', '-t', target, 'C-c', 'Up', 'Enter' }, { detach = true })
  vim.notify(string.format('Restarted %s', title), vim.log.levels.INFO)
end

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
