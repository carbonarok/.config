return {
  'linux-cultist/venv-selector.nvim',
  dependencies = {
    'neovim/nvim-lspconfig',
    { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } }, -- optional: you can also use fzf-lua, snacks, mini-pick instead.
  },
  ft = 'python', -- Load when opening Python files
  keys = {
    { ',v', '<cmd>VenvSelect<cr>' }, -- Open picker on keymap
  },
  opts = {
    options = {},
    search = {
      my_venvs = {
        command = 'fd python$ /Users/opti-mac/Library/Caches/pypoetry/virtualenvs/', -- Sample command, need to be changed for your own venvs
        -- If you put the callback here, its only called for your "my_venvs" search
      },
    },
  },
}

