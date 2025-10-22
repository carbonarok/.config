return {
  'nvimdev/galaxyline.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  lazy = false,
  config = function()
    -- Global statusline (Neovim 0.7+)
    vim.o.laststatus = 3

    local gl = require 'galaxyline'
    local gls = gl.section
    local condition = require 'galaxyline.condition'

    -- ── Colors (tweak to taste)
    local palette = {
      bg = '#1e1e2e',
      fg = '#cdd6f4',
      dim = '#6c7086',
      cyan = '#89dceb',
      green = '#a6e3a1',
      yellow = '#f9e2af',
      orange = '#fab387',
      red = '#f38ba8',
      magenta = '#f5c2e7',
      blue = '#89b4fa',
    }

    -- Mode → color map
    local mode_color = {
      n = palette.blue,
      i = palette.green,
      v = palette.magenta,
      [''] = palette.magenta, -- visual block
      V = palette.magenta,
      c = palette.orange,
      R = palette.red,
      t = palette.cyan,
    }

    -- Common highlight helpers
    local function hl(left, right)
      return { bg = left or palette.bg, fg = right or palette.fg }
    end
    local function vi_color()
      return mode_color[vim.fn.mode()] or palette.blue
    end

    -- Shortline (inactive/special windows)
    gl.short_line_list = { 'NvimTree', 'neo-tree', 'packer', 'help', 'qf', 'dashboard' }

    -- LEFT
    gls.left = {
      -- 1) Mode pill
      {
        ViMode = {
          provider = function()
            local m = vim.fn.mode()
            local map = {
              n = 'NORMAL',
              i = 'INSERT',
              v = 'VISUAL',
              V = 'V-LINE',
              [''] = 'V-BLOCK',
              c = 'COMMAND',
              R = 'REPLACE',
              t = 'TERMINAL',
            }
            return '  ' .. (map[m] or m) .. ' '
          end,
          highlight = function()
            return { fg = palette.bg, bg = vi_color(), gui = 'bold' }
          end,
          separator = ' ',
          separator_highlight = hl(),
        },
      },

      -- 2) Git branch
      {
        GitBranch = {
          provider = 'GitBranch',
          condition = condition.check_git_workspace,
          icon = ' ',
          highlight = hl(nil, palette.fg),
          separator = ' ',
          separator_highlight = hl(),
        },
      },

      -- 3) Diff
      {
        DiffAdd = {
          provider = 'DiffAdd',
          condition = condition.hide_in_width,
          icon = ' ',
          highlight = { fg = palette.green, bg = palette.bg },
        },
      },
      {
        DiffModified = {
          provider = 'DiffModified',
          condition = condition.hide_in_width,
          icon = ' ',
          highlight = { fg = palette.yellow, bg = palette.bg },
        },
      },
      {
        DiffRemove = {
          provider = 'DiffRemove',
          condition = condition.hide_in_width,
          icon = ' ',
          highlight = { fg = palette.red, bg = palette.bg },
          separator = '  ',
          separator_highlight = hl(),
        },
      },

      -- 4) File icon + name
      {
        FileIcon = {
          provider = 'FileIcon',
          condition = condition.buffer_not_empty,
          highlight = function()
            return { fg = vim.bo.modified and palette.yellow or palette.cyan, bg = palette.bg }
          end,
        },
      },
      {
        FileName = {
          provider = function()
            local name = require('galaxyline.provider_fileinfo').get_current_file_name()
            if vim.bo.readonly then
              name = name .. ' '
            end
            if vim.bo.modified then
              name = name .. ' ●'
            end
            return ' ' .. name .. ' '
          end,
          highlight = hl(),
        },
      },

      -- 5) LSP status (only if attached)
      {
        LspClient = {
          provider = function()
            local buf = vim.api.nvim_get_current_buf()
            local clients = vim.lsp.get_clients { bufnr = buf }
            if not clients or #clients == 0 then
              return ''
            end
            local names = {}
            for _, c in ipairs(clients) do
              table.insert(names, c.name)
            end
            return '  ' .. table.concat(names, ', ') .. ' '
          end,
          highlight = { fg = palette.cyan, bg = palette.bg },
          condition = function()
            local buf = vim.api.nvim_get_current_buf()
            return #vim.lsp.get_clients { bufnr = buf } > 0
          end,
          separator = ' ',
          separator_highlight = hl(),
        },
      },

      -- 6) Diagnostics
      {
        DiagnosticError = {
          provider = 'DiagnosticError',
          icon = ' ',
          highlight = { fg = palette.red, bg = palette.bg },
        },
      },
      {
        DiagnosticWarn = {
          provider = 'DiagnosticWarn',
          icon = ' ',
          highlight = { fg = palette.orange, bg = palette.bg },
        },
      },
      {
        DiagnosticInfo = {
          provider = 'DiagnosticInfo',
          icon = ' ',
          highlight = { fg = palette.blue, bg = palette.bg },
        },
      },
      {
        DiagnosticHint = {
          provider = 'DiagnosticHint',
          icon = '󰌵 ',
          highlight = { fg = palette.dim, bg = palette.bg },
        },
      },
    }

    -- RIGHT
    gls.right = {
      -- 1) Encoding / Format / Filetype
      {
        FileType = {
          provider = 'FileTypeName',
          icon = '󰈤 ',
          highlight = hl(nil, palette.fg),
          separator = ' ',
          separator_highlight = hl(),
        },
      },
      {
        FileFormat = {
          provider = 'FileFormat',
          icon = ' ',
          highlight = hl(nil, palette.fg),
          condition = condition.hide_in_width,
          separator = ' ',
          separator_highlight = hl(),
        },
      },
      {
        FileEncode = {
          provider = 'FileEncode',
          icon = '󰗊 ',
          highlight = hl(nil, palette.fg),
          condition = condition.hide_in_width,
          separator = ' ',
          separator_highlight = hl(),
        },
      },

      -- 2) Position + percent + scrollbar
      {
        LineColumn = {
          provider = 'LineColumn', -- <line>:<col>
          icon = ' ',
          highlight = { fg = palette.yellow, bg = palette.bg },
          separator = ' ',
          separator_highlight = hl(),
        },
      },
      {
        PerCent = {
          provider = 'LinePercent',
          icon = ' ',
          highlight = { fg = palette.magenta, bg = palette.bg },
          separator = ' ',
          separator_highlight = hl(),
        },
      },
      {
        ScrollBar = {
          provider = 'ScrollBar',
          highlight = { fg = palette.green, bg = palette.bg },
        },
      },
    }

    -- INACTIVE (short) LEFT/RIGHT
    gls.short_line_left = {
      {
        InactiveFile = {
          provider = function()
            return ' ' .. require('galaxyline.provider_fileinfo').get_current_file_name() .. ' '
          end,
          highlight = hl(palette.bg, palette.dim),
        },
      },
    }
    gls.short_line_right = {
      { BufferIcon = { provider = 'BufferIcon', highlight = hl() } },
    }
  end,
}
