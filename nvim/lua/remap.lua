local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    if opts.desc then
      opts.desc = 'keymaps.lua: ' .. opts.desc
    end
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

local opts = { noremap = true, silent = true }

map('n', '<C-s>', '<cmd>w<CR>', opts)
map('i', '<C-s>', '<cmd>w<CR><ESC>', opts)

vim.keymap.set({ 'n', 'v' }, '<leader>gf', function()
  require('git_branch').files()
end)

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

map('n', '<C-u>', '<C-u>zz', opts)
map('n', '<C-d>', '<C-d>zz', opts)

map('x', '<leader>p', '"_dP')
map('n', '<leader>gs', '<cmd>Telescope git_status<CR>', opts)
map('n', '<leader>r', '<cmd>source $MYVIMRC<CR>', opts)

-- Window moving
map('n', '<leader>wh', '<C-w>H', opts)
map('n', '<leader>wj', '<C-w>J', opts)
map('n', '<leader>wk', '<C-w>K', opts)
map('n', '<leader>wl', '<C-w>L', opts)

-- Buffer switching
map('n', '<leader>1', '<cmd>BufferLineGoToBuffer 1<CR>', opts)
map('n', '<leader>2', '<cmd>BufferLineGoToBuffer 2<CR>', opts)
map('n', '<leader>3', '<cmd>BufferLineGoToBuffer 3<CR>', opts)
map('n', '<leader>4', '<cmd>BufferLineGoToBuffer 4<CR>', opts)
map('n', '<leader>5', '<cmd>BufferLineGoToBuffer 5<CR>', opts)
map('n', '<leader>6', '<cmd>BufferLineGoToBuffer 6<CR>', opts)
map('n', '<leader>7', '<cmd>BufferLineGoToBuffer 7<CR>', opts)
map('n', '<leader>8', '<cmd>BufferLineGoToBuffer 8<CR>', opts)
map('n', '<leader>9', '<cmd>BufferLineGoToBuffer 9<CR>', opts)
map('n', '<leader>0', '<cmd>BufferLineGoToBuffer 10<CR>', opts)

-- Close all but current
vim.keymap.set('n', '<leader>bo', ':BufferLineCloseOthers<CR>', { desc = 'Close others' })

-- Close left/right
vim.keymap.set('n', '<leader>bh', ':BufferLineCloseLeft<CR>', { desc = 'Close left' })
vim.keymap.set('n', '<leader>bl', ':BufferLineCloseRight<CR>', { desc = 'Close right' })

-- Close current (safe)
vim.keymap.set('n', '<leader>bc', function()
  local cur_buf = vim.api.nvim_get_current_buf()
  vim.cmd('bnext') -- move to next buffer
  vim.cmd('bdelete ' .. cur_buf)
end, { desc = 'Close current buffer safely' })

-- Close ALL (custom)
vim.keymap.set('n', '<leader>ba', ':%bd|e#<CR>', { desc = 'Close all buffers' })

-- Octo Githut Shortcuts
vim.keymap.set('n', '<leader>ghil', ':Octo issue list<CR>', { desc = 'List issues' })
vim.keymap.set('n', '<leader>ghic', ':Octo issue create<CR>', { desc = 'Create issue' })

-- CSpell
vim.keymap.set(
  'n',
  '<leader>as',
  ":lua require('null-ls').builtins.code_actions.cspell()<CR>",
  { desc = 'Apply cspell suggestion' }
)

vim.keymap.set('n', '<leader>mt', '<cmd>SupermavenToggle<CR>', { desc = 'SuperMaven Toggle' })

-- Normal mode: move current line
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { silent = true })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { silent = true })

-- Visual mode: move selected lines
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { silent = true })

-- Run previous command in better-term terminal
vim.keymap.set('n', '<leader>rp', function()
  local bt = require('betterTerm')
  bt.send('fc -s\r')
end, { desc = 'Run previous terminal command' })

vim.keymap.set('n', '<leader>tv', function()
  require('betterTerm').open(nil, { direction = 'vertical' })
end, { desc = 'Open BetterTerm vertically' })

-- Search center
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Search center' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Search center' })

-- Save and quit
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save' })
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = 'Quit' })
vim.keymap.set('n', '<leader>wq', ':wq<CR>', { desc = 'Save and quit' })

-- Resize
vim.keymap.set('n', '<A-h>', ':vertical resize -2<CR>', { desc = 'Resize pane up' })
vim.keymap.set('n', '<A-l>', ':vertical resize +2<CR>', { desc = 'Resize pane down' })
vim.keymap.set('n', '<A-k>', ':resize -2<CR>', { desc = 'Resize pane left' })
vim.keymap.set('n', '<A-j>', ':resize +2<CR>', { desc = 'Resize pane right' })

-- Selected pasted text
vim.keymap.set('n', 'gp', '`[v`]', {})

-- Jump to indentation
vim.keymap.set('n', '<leader>j', '^', { desc = 'Jump to indentation' })
vim.keymap.set('v', '<leader>j', '^', { desc = 'Jump to indentation' })
vim.keymap.set('n', '<leader>I', '$', { desc = 'Jump to indentation' })
vim.keymap.set('v', '<leader>I', '$', { desc = 'Jump to indentation' })

-- Sort in Visual mode
vim.keymap.set('v', '<leader>s', ':sort<CR>', { desc = 'Sort in Visual mode' })
