return {
  'sindrets/diffview.nvim',
  dependencies = 'nvim-lua/plenary.nvim',
  config = function()
    require('diffview').setup()
    vim.keymap.set('n', '<leader>dvo', function()
      require('diffview').open()
    end, { desc = 'Open diffview' })
    vim.keymap.set('n', '<leader>dvc', function()
      require('diffview').close()
    end, { desc = 'Close diffview' })
  end,
}
