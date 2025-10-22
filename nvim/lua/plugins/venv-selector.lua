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
    options = {
      -- If you put the callback here as a global option, its used for all searches (including the default ones by the plugin)
    },
    search = {
      my_venvs = {
        command = 'fd -t f -t l python$ $(poetry config virtualenvs.path || true) ./',
        -- If you put the callback here, its only called for your "my_venvs" search
      },
    },
  },
}
