return {
  'pwntester/octo.nvim',
  cmd = 'Octo',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    { '<leader>oi', '<cmd>Octo issue list<CR>', desc = 'List issues' },
    { '<leader>op', '<cmd>Octo pr list<CR>', desc = 'List PRs' },
  },
  config = function()
    require('octo').setup()
  end,
}
