return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  event = 'BufReadPost',
  opts = {
    indent = {
      char = '▏', -- Thin, clean indent line (alternatives: "│", "▎", "┆")
      highlight = {
        'IndentLevel1',
        'IndentLevel2',
        'IndentLevel3',
        'IndentLevel4',
      },
    },
    scope = {
      enabled = true,
      show_start = false,
      show_end = false,
      highlight = 'IndentScope',
    },
    whitespace = {
      remove_blankline_trail = true,
    },
    exclude = {
      filetypes = {
        'help',
        'dashboard',
        'lazy',
        'mason',
        'neo-tree',
        'NvimTree',
        'Trouble',
        'text',
        'markdown',
      },
      buftypes = { 'terminal', 'nofile', 'quickfix' },
    },
  },
  config = function(_, opts)
    -- Custom highlight groups for subtle rainbow colors
    vim.api.nvim_set_hl(0, 'IndentLevel1', { fg = '#3b4261', nocombine = true })
    vim.api.nvim_set_hl(0, 'IndentLevel2', { fg = '#434c5e', nocombine = true })
    vim.api.nvim_set_hl(0, 'IndentLevel3', { fg = '#4c566a', nocombine = true })
    vim.api.nvim_set_hl(0, 'IndentLevel4', { fg = '#616e88', nocombine = true })
    vim.api.nvim_set_hl(0, 'IndentScope', { fg = '#88c0d0', bold = true, nocombine = true })

    require('ibl').setup(opts)
  end,
}
