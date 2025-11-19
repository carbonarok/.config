return {
  'scottmckendry/cyberdream.nvim',
  priority = 1000,
  config = function()
    local transparent = true

    local bg = '#011628'
    local bg_dark = '#011423'
    local bg_high = '#143652'
    local fg = '#CBE0F0'
    local fg_dark = '#B4D0E9'
    local fg_gutter = '#627E97'
    local border = '#547998'

    require('cyberdream').setup({
      transparent = transparent,
      italic_comments = true,
      hide_fillchars = true,
      borderless_telescope = true,

      colors = {
        bg = bg,
        bgAlt = bg_dark,
        bgHighlight = bg_high,
        fg = fg,
        fgAlt = fg_dark,
        border = border,
        comment = fg_gutter,
      },

      highlights = {
        Comment = { fg = fg_gutter, italic = true },
        LineNr = { fg = fg_gutter },
        CursorLine = { bg = bg_high },
        CursorLineNr = { fg = fg, bold = true },
        VertSplit = { fg = border },
        Visual = { bg = bg_high },
      },
    })

    vim.cmd('colorscheme cyberdream')

    vim.api.nvim_set_hl(0, 'NormalFloat', { bg = bg_dark })
    vim.api.nvim_set_hl(0, 'FloatBorder', { bg = bg_dark, fg = border })
    vim.api.nvim_set_hl(0, 'Pmenu', { bg = bg_dark })
    vim.api.nvim_set_hl(0, 'PmenuSel', { bg = bg_high })
    vim.api.nvim_set_hl(0, 'WinSeparator', { fg = border, bg = none })

    vim.opt.fillchars = {
      vert = '│',
      horiz = '─',
      horizup = '┴',
      horizdown = '┬',
      vertleft = '┤',
      vertright = '├',
      verthoriz = '┼',
    }

    vim.api.nvim_set_hl(0, 'TelescopeNormal', { bg = none })
    vim.api.nvim_set_hl(0, 'TelescopePromptNormal', { bg = none })
    vim.api.nvim_set_hl(0, 'TelescopeResultsNormal', { bg = none })
    vim.api.nvim_set_hl(0, 'TelescopePreviewNormal', { bg = none })

    vim.api.nvim_set_hl(0, 'TelescopeBorder', { bg = none })
    vim.api.nvim_set_hl(0, 'TelescopePromptBorder', { bg = none })
    vim.api.nvim_set_hl(0, 'TelescopeResultsBorder', { bg = none })
    vim.api.nvim_set_hl(0, 'TelescopePreviewBorder', { bg = none })

    vim.api.nvim_set_hl(0, 'CmpPmenu', { bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'CmpPmenuBorder', { bg = 'NONE', fg = border })
    vim.api.nvim_set_hl(0, 'CmpPmenuSel', { bg = bg_high }) -- selected item
    vim.api.nvim_set_hl(0, 'CmpPmenuThumb', { bg = 'NONE' })
  end,
}
