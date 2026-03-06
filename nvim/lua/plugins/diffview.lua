return {
  'sindrets/diffview.nvim',
  dependencies = 'nvim-lua/plenary.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
  keys = {
    { '<leader>dvo', '<cmd>DiffviewOpen<CR>', desc = 'Open diffview' },
    { '<leader>dvc', '<cmd>DiffviewClose<CR>', desc = 'Close diffview' },
    { '<leader>dvh', '<cmd>DiffviewFileHistory %<CR>', desc = 'File history' },
  },
  config = function()
    require('diffview').setup()
  end,
}
