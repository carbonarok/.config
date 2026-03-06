return {
  'stevearc/oil.nvim',
  lazy = false,
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  opts = {
    default_file_explorer = true,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    view_options = {
      show_hidden = true,
    },
    float = {
      padding = 2,
      border = 'rounded',
    },
    keymaps = {
      ['<C-c>'] = { 'actions.close', mode = 'n' },
      ['<CR>'] = 'actions.select',
      ['-'] = { 'actions.parent', mode = 'n' },
      ['_'] = { 'actions.open_cwd', mode = 'n' },
      ['gs'] = { 'actions.change_sort', mode = 'n' },
      ['g.'] = { 'actions.toggle_hidden', mode = 'n' },
      ['gx'] = 'actions.open_external',
      ['g\\'] = { 'actions.toggle_trash', mode = 'n' },
    },
    use_default_keymaps = false,
  },
}
