return {
  'Eutrius/Otree.nvim',
  lazy = false,
  dependencies = {
    'stevearc/oil.nvim',
    's1n7ax/nvim-window-picker',
  },
  keys = {
    { '<leader>e', '<cmd>Otree<CR>', desc = 'Toggle Otree' },
  },
  config = function()
    require('Otree').setup({
      win_size = 30,
      open_on_startup = true,
      use_default_keymaps = false,
      hijack_netrw = true,
      show_hidden = false,
      show_ignore = true,
      cursorline = true,
      focus_on_enter = false,
      open_on_left = false,
      git_signs = true,
      lsp_signs = true,
      oil = 'float',
      ignore_patterns = {},

      keymaps = {
        -- Open
        ['<CR>'] = 'actions.select',
        ['l'] = 'actions.select',
        -- 'w' is handled separately via autocmd to use window-picker
        ['t'] = 'actions.open_tab',    -- open in tab   (neotree: t)
        ['s'] = 'actions.open_split',  -- horizontal    (neotree: s)
        ['v'] = 'actions.open_vsplit', -- vertical      (neotree: v)
        -- Navigation
        ['h'] = 'actions.close_dir',
        ['H'] = 'actions.close_dirs',
        ['L'] = 'actions.open_dirs',
        ['-'] = 'actions.goto_parent',
        ['+'] = 'actions.goto_dir',
        ['cd'] = 'actions.change_home_dir',
        -- Oil
        ['o'] = 'actions.oil_dir',
        ['O'] = 'actions.oil_into_dir',
        -- Misc
        ['\\'] = 'actions.close_win',
        ['<Esc>'] = 'actions.close_win',
        ['.'] = 'actions.toggle_hidden',
        ['i'] = 'actions.toggle_ignore',
        ['r'] = 'actions.refresh',
        ['f'] = 'actions.focus_file',
        ['?'] = 'actions.open_help',
      },

      tree = {
        space_after_icon = ' ',
        space_after_connector = ' ',
        connector_space = ' ',
        connector_last = '└',
        connector_middle = '├',
        vertical_line = '│',
      },

      icons = {
        title = ' ',
        default_file = '',
        default_directory = '',
        empty_dir = '',
        trash = ' ',
        keymap = '⌨ ',
        oil = ' ',
      },

      highlights = {
        directory = 'Directory',
        file = 'Normal',
        tree = 'Comment',
        title = 'Title',
        float_normal = 'NormalFloat',
        float_border = 'FloatBorder',
        link_path = 'Comment',
        git_ignored = 'NonText',
        git_untracked = 'DiagnosticInfo',
        git_modified = 'DiagnosticWarn',
        git_added = 'DiagnosticHint',
        git_deleted = 'DiagnosticError',
        git_conflict = 'DiagnosticError',
        git_renamed = 'DiagnosticHint',
        git_copied = 'DiagnosticHint',
        lsp_warn = 'DiagnosticWarn',
        lsp_info = 'DiagnosticInfo',
        lsp_hint = 'DiagnosticHint',
        lsp_error = 'DiagnosticError',
      },

      float = {
        center = true,
        width_ratio = 0.4,
        height_ratio = 0.7,
        padding = 2,
        cursorline = true,
        border = 'rounded',
      },
    })

    -- Wire window-picker into 'w' since otree keymaps only accept string action names
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'Otree',
      callback = function(ev)
        vim.keymap.set('n', 'w', function()
          local state = require('Otree.state')
          local cursor = vim.api.nvim_win_get_cursor(state.win)
          local node = state.nodes[cursor[1]]
          if not node or node.type ~= 'file' then return end
          local picked_win = require('window-picker').pick_window()
          if picked_win then
            vim.api.nvim_set_current_win(picked_win)
            vim.cmd('edit ' .. vim.fn.fnameescape(node.full_path))
          end
        end, { buffer = ev.buf, nowait = true, desc = 'Open with window picker' })
      end,
    })
  end,
}
