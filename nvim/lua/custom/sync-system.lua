local function push_to_git(path, message)
  local full_path = vim.fn.expand(path)

  if vim.fn.isdirectory(full_path) == 0 then
    vim.notify('Path is not a directory', vim.log.levels.ERROR)
    return
  end

  local current_path = vim.fn.getcwd()

  vim.cmd('cd ' .. full_path)
  vim.cmd('!git add .')
  vim.cmd("!git commit -m '%s'", message)
  vim.cmd('!git push')

  vim.cmd('cd ' .. current_path)
end

local function pull_from_git(path)
  local full_path = vim.fn.expand(path)

  if vim.fn.isdirectory(full_path) == 0 then
    vim.notify('Path is not a directory', vim.log.levels.ERROR)
    return
  end

  vim.cmd('cd ' .. full_path)
  vim.cmd('!git pull')
end

local function reload_config()
  for name, _ in pairs(package.loaded) do
    if name:match('^custom') or name:match('^user') or name:match('^plugins') then
      package.loaded[name] = nil
    end
  end

  pcall(require, 'init') -- or whatever your top-level module is

  vim.notify('Config reloaded (modules only). Use :Lazy reload for plugins.', vim.log.levels.INFO)
end

vim.keymap.set('n', '<leader>cp', function()
  vim.ui.input({ prompt = 'Enter commit message: ' }, function(message)
    push_to_git('~/.config', message)
  end)
end, { desc = 'Push ~/.config to git' })

vim.keymap.set('n', '<leader>cs', function()
  pull_from_git('~/.config')
  reload_config()
end, { desc = 'Pull ~/.config from git' })

vim.keymap.set('n', '<leader>cr', function()
  reload_config()
end, { desc = 'Reload ~/.config' })
