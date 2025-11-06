return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    's1n7ax/nvim-window-picker',
    'MunifTanjim/nui.nvim',
    'akinsho/bufferline.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
    update_focused_file = {
      enable = true,
      update_root = true,
    },
    event_handlers = {
      {
        event = 'neo_tree_buffer_enter',
        handler = function()
          vim.opt_local.number = true
          vim.opt_local.relativenumber = true
          vim.cmd([[
          setlocal relativenumber
        ]])
        end,
      },
    },
    source_selector = {
      winbar = true,
      statusline = false,
      show_scrolled_off_parent_node = false,
      sources = {
        { source = 'filesystem', display_name = ' 󰉓 Files ' },
        { source = 'buffers', display_name = '  Buffers ' },
        { source = 'git_status', display_name = ' 󰊢 Git ' },
      },
      content_layout = 'start',
      tabs_layout = 'equal',
      truncation_character = '…',
      tabs_min_width = nil,
      tabs_max_width = nil,
      padding = 0,
      separator = { left = '▏', right = '▕' },
      separator_active = nil,
      show_separator_on_edge = false,
      highlight_tab = 'NeoTreeTabInactive',
      highlight_tab_active = 'NeoTreeTabActive',
      highlight_background = 'NeoTreeTabInactive',
      highlight_separator = 'NeoTreeTabSeparatorInactive',
      highlight_separator_active = 'NeoTreeTabSeparatorActive',
    },
    window = { use_default_mappings = true },
    filesystem = {
      -- follow_current_file = { enabled = true },
      follow_current_file = { enabled = true, leave_dirs_open = true },
      use_libuv_file_watcher = true,
      bind_to_cwd = true,
      buffers = {
        follow_current_file = true,
        group_empty_dirs = true,
        show_unloaded = true,
      },
      cwd_target = {
        sidebar = 'tab',
        current = 'window',
      },
      window = {
        use_default_mappings = true,
        mappings = {
          ['<cr>'] = function(state)
            local node = state.tree:get_node()
            if node.path:match('/%.?venv/') then
              return
            end
            require('neo-tree.sources.filesystem.commands').open(state)
          end,
          ['<space>'] = 'none',
          ['\\'] = 'close_window',
          ['h'] = 'close_node',
          ['l'] = 'open',
          ['s'] = 'open_split',
          ['v'] = 'open_vsplit',
        },
        position = 'right',
        width = 40,
      },
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_by_name = {
          '.DS_Store',
          'thumbs.db',
        },
        never_show = {
          '.DS_Store',
          'thumbs.db',
        },
      },
    },
  },
}
