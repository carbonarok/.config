vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = {
  -- space = '·',
  tab = '» ',
  trail = '·',
  nbsp = '␣',
}

vim.env.PATH = '/opt/homebrew/bin:/usr/local/bin:' .. vim.env.PATH

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

vim.o.confirm = true

vim.o.termguicolors = true
vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,localoptions'

vim.o.winbar = '%=%f%m'

vim.opt.laststatus = 3
vim.opt.showtabline = 2

vim.opt.fillchars = {
  vert = '│',
  horiz = '─',
  horizup = '┴',
  horizdown = '┬',
  vertleft = '┤',
  vertright = '├',
  verthoriz = '┼',
}

vim.opt.iskeyword:append({ '-', '_' })
-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w><C-h>]], { desc = 'Move focus to the left window' })
vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w><C-l>]], { desc = 'Move focus to the right window' })
vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w><C-j>]], { desc = 'Move focus to the lower window' })
vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w><C-k>]], { desc = 'Move focus to the upper window' })
vim.keymap.set('t', 'TmuxNavigateUp', '[[<C-><C-n><C-w>k]]', { desc = 'Move focus to the upper window' })
vim.keymap.set('t', 'TmuxNavigateDown', '[[<C-><C-n><C-w>j]]', { desc = 'Move focus to the lower window' })
vim.keymap.set('t', 'TmuxNavigateLeft', '[[<C-><C-n><C-w>h]]', { desc = 'Move focus to the left window' })
vim.keymap.set('t', 'TmuxNavigateRight', '[[<C-><C-n><C-w>l]]', { desc = 'Move focus to the right window' })

-- For tabs bufferline
vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>', { silent = true })
vim.keymap.set('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', { silent = true })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
vim.keymap.set('n', '<C-S-h>', '<C-w>H', { desc = 'Move window to the left' })
vim.keymap.set('n', '<C-S-l>', '<C-w>L', { desc = 'Move window to the right' })
vim.keymap.set('n', '<C-S-j>', '<C-w>J', { desc = 'Move window to the lower' })
vim.keymap.set('n', '<C-S-k>', '<C-w>K', { desc = 'Move window to the upper' })

-- Insert mode movements
vim.keymap.set('i', '<A-h>', '<Left>')
vim.keymap.set('i', '<A-j>', '<Down>')
vim.keymap.set('i', '<A-k>', '<Up>')
vim.keymap.set('i', '<A-l>', '<Right>')

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({

  -- { -- Collection of various small independent plugins/modules
  --   'echasnovski/mini.nvim',
  --   config = function()
  --     require('mini.ai').setup({ n_lines = 500 })
  --     require('mini.surround').setup()
  --   end,
  -- },

  require('kickstart.plugins.autopairs'),
  require('kickstart.plugins.gitsigns'),
  require('kickstart.plugins.lint'),
  require('plugins.auto-format'),
  require('plugins.auto-session'),
  require('plugins.betterTerm'),
  require('plugins.blink'),
  require('plugins.bufferline'),
  require('plugins.colour-scheme'),
  require('plugins.comment'),
  require('plugins.cspell'),
  require('plugins.diffview'),
  require('plugins.galaxyline'),
  require('plugins.gitsigns'),
  require('plugins.harpoon'),
  require('plugins.indent-blankline'),
  require('plugins.lazydev'),
  require('plugins.local-config'),
  require('plugins.log-highlight'),
  require('plugins.neo-tree'),
  require('plugins.nvim-dap'),
  require('plugins.nvim-lspconfig'),
  require('plugins.nvim-surround'),
  require('plugins.nvim-treesitter'),
  require('plugins.octo'),
  require('plugins.project'),
  require('plugins.supermaven'),
  require('plugins.telescope'),
  require('plugins.to-do'),
  require('plugins.typr'),
  require('plugins.venv-selector'),
  require('plugins.vim-tmux-navigator'),
  require('plugins.vim-visual-multi'),
  require('plugins.vimtex'),
  require('plugins.which-key'),
  -- require('plugins.nvim-treesitter-rainbow'),
  -- require('kickstart.plugins.debug'),
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

require('remap')
require('python-debug')
require('custom.sync-system')
require('custom.tmux')
require('custom.file-types')
