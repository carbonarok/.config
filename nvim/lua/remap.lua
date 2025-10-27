vim.keymap.set('n', '<leader>/', function()
  require('telescope.builtin').live_grep({
    prompt_title = '🔍 Search in files',
    cwd = vim.loop.cwd(),
  })
end, { desc = 'Search all files' })

vim.keymap.set('n', '<leader>k', function()
  require('telescope.builtin').keymaps()
end, { desc = 'Search keymaps' })

vim.keymap.set('n', '<leader>f', function()
  require('telescope.builtin').find_files()
end, { desc = 'Search files' })

vim.keymap.set('n', '<leader>s', function()
  require('telescope.builtin').grep_string()
end, { desc = 'Search string' })

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
vim.keymap.set('n', '<leader>bc', ':bdelete<CR>', { desc = 'Close current buffer' })

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
