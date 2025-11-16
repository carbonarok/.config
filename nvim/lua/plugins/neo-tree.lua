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
    -- Files (filesystem source)
    { '\\', ':Neotree source=filesystem reveal position=right<CR>', desc = 'NeoTree Files', silent = true },

    -- Git status: show only files affected by git
    {
      '<leader>gt',
      function()
        require('neo-tree.command').execute({
          source = 'git_status',
          position = 'right',
          toggle = true, -- open if closed, close if already on git_status
        })
      end,
      desc = 'NeoTree Git status',
      silent = true,
    },
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
        end,
      },
    },

    -- tabs at the top (one active source at a time)
    source_selector = {
      winbar = false,
      statusline = false,
      show_scrolled_off_parent_node = false,
      sources = {
        { source = 'filesystem', display_name = ' 󰉓 Files ' },
        { source = 'git_status', display_name = ' 󰊢 Git ' },
      },
      content_layout = 'start',
      tabs_layout = 'equal',
      truncation_character = '…',
      padding = 0,
      separator = { left = '▏', right = '▕' },
      highlight_tab = 'NeoTreeTabInactive',
      highlight_tab_active = 'NeoTreeTabActive',
      highlight_background = 'NeoTreeTabInactive',
      highlight_separator = 'NeoTreeTabSeparatorInactive',
      highlight_separator_active = 'NeoTreeTabSeparatorActive',
    },

    window = {
      use_default_mappings = true,
    },

    filesystem = {
      follow_current_file = { enabled = true, leave_dirs_open = true },
      use_libuv_file_watcher = true,
      bind_to_cwd = true,
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

    -- (optional) you can also add a top-level `git_status = {}` section to tweak how it looks
  },
}
