return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  lazy = false,
  config = function()
    -- Approximations of rgba(...) on dark backgrounds
    -- rgba(255,255,64,0.07)  → #3a3a12 (soft yellow)
    -- rgba(127,255,127,0.07) → #1e3a1e (minty green)
    -- rgba(255,127,255,0.07) → #3a1e3a (rose)
    -- rgba(79,236,236,0.07)  → #123a3a (cyan)
    vim.cmd([[highlight IndentBlanklineIndent1 guibg=#3a3a12 gui=nocombine]])
    vim.cmd([[highlight IndentBlanklineIndent2 guibg=#1e3a1e gui=nocombine]])
    vim.cmd([[highlight IndentBlanklineIndent3 guibg=#3a1e3a gui=nocombine]])
    vim.cmd([[highlight IndentBlanklineIndent4 guibg=#123a3a gui=nocombine]])

    require('ibl').setup({
      indent = {
        char = '',
        highlight = {
          'IndentBlanklineIndent1',
          'IndentBlanklineIndent2',
          'IndentBlanklineIndent3',
          'IndentBlanklineIndent4',
        },
      },
      whitespace = {
        highlight = {
          'IndentBlanklineIndent1',
          'IndentBlanklineIndent2',
          'IndentBlanklineIndent3',
          'IndentBlanklineIndent4',
        },
        remove_blankline_trail = true,
      },
      scope = { enabled = false },
    })
  end,
}
