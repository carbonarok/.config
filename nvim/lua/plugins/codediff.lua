return {
  'esmuellert/codediff.nvim',
  dependencies = { 'MunifTanjim/nui.nvim' },
  cmd = 'CodeDiff',
  config = function()
    require('codediff').setup({
      explorer = {
        position = 'right',
        view_mode = 'tree',
      },

      keymaps = {
        explorer = {
          select = 'l',
        },
      },
    })
  end,
}
