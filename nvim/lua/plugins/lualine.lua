return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  lazy = false,
  config = function()
    local colors = {
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

    local custom_theme = {
      normal = {
        a = { fg = colors.bg, bg = colors.blue, gui = 'bold' },
        b = { fg = colors.fg, bg = colors.bg },
        c = { fg = colors.fg, bg = colors.bg },
      },
      insert = {
        a = { fg = colors.bg, bg = colors.green, gui = 'bold' },
      },
      visual = {
        a = { fg = colors.bg, bg = colors.magenta, gui = 'bold' },
      },
      replace = {
        a = { fg = colors.bg, bg = colors.red, gui = 'bold' },
      },
      command = {
        a = { fg = colors.bg, bg = colors.orange, gui = 'bold' },
      },
      inactive = {
        a = { fg = colors.dim, bg = colors.bg },
        b = { fg = colors.dim, bg = colors.bg },
        c = { fg = colors.dim, bg = colors.bg },
      },
    }

    -- Custom component for SuperMaven status
    local function supermaven_status()
      local ok, api = pcall(require, 'supermaven-nvim.api')
      if not ok then
        return ''
      end
      local running = api.is_running and api.is_running()
      return running and '󰒋 SM' or ''
    end

    require('lualine').setup({
      options = {
        theme = custom_theme,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        globalstatus = true,
        disabled_filetypes = {
          statusline = { 'dashboard', 'NvimTree', 'neo-tree' },
        },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = {
          { 'branch', icon = '' },
          {
            'diff',
            symbols = { added = ' ', modified = ' ', removed = ' ' },
            diff_color = {
              added = { fg = colors.green },
              modified = { fg = colors.yellow },
              removed = { fg = colors.red },
            },
          },
        },
        lualine_c = {
          {
            'filename',
            path = 1, -- relative path
            symbols = {
              modified = ' ●',
              readonly = ' ',
              unnamed = '[No Name]',
            },
          },
          {
            'diagnostics',
            sources = { 'nvim_diagnostic' },
            symbols = { error = ' ', warn = ' ', info = ' ', hint = '󰌶 ' },
            diagnostics_color = {
              error = { fg = colors.red },
              warn = { fg = colors.orange },
              info = { fg = colors.blue },
              hint = { fg = colors.dim },
            },
          },
        },
        lualine_x = {
          supermaven_status,
          {
            -- LSP client names
            function()
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if #clients == 0 then
                return ''
              end
              local names = {}
              for _, client in ipairs(clients) do
                table.insert(names, client.name)
              end
              return ' ' .. table.concat(names, ', ')
            end,
            color = { fg = colors.cyan },
          },
          'encoding',
          { 'fileformat', icons_enabled = true },
          'filetype',
        },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = { 'neo-tree', 'lazy', 'toggleterm', 'quickfix' },
    })
  end,
}
