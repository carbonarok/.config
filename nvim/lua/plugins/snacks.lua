return {
  'folke/snacks.nvim',
  enabled = false, -- Temporarily disabled for debugging
  priority = 1000,
  lazy = false,
  opts = {
    -- Dashboard - Disabled (conflicts with auto-session and opening files directly)
    dashboard = { enabled = false },

    -- Notifier - Better notification system
    notifier = {
      enabled = true,
      timeout = 3000,
      style = 'compact',
    },

    -- Quickfile - Disabled (can conflict with neo-tree)
    quickfile = { enabled = false },

    -- Statuscolumn - Enhanced sign column
    statuscolumn = { enabled = true },

    -- Words - Highlight word under cursor
    words = { enabled = true },

    -- Bigfile - Handle large files gracefully
    bigfile = {
      enabled = true,
      size = 1.5 * 1024 * 1024, -- 1.5MB
    },

    -- Indent - Animated indent guides
    indent = {
      enabled = true,
      animate = {
        enabled = true,
        duration = {
          step = 20,
          total = 200,
        },
      },
    },

    -- Input - Better vim.ui.input
    input = { enabled = true },

    -- Scope - Scope detection for indent guides
    scope = { enabled = true },

    -- Scroll - Smooth scrolling
    scroll = { enabled = true },

    -- Zen - Zen mode
    zen = { enabled = true },
  },
  keys = {
    {
      '<leader>n',
      function()
        Snacks.notifier.show_history()
      end,
      desc = 'Notification History',
    },
    {
      '<leader>un',
      function()
        Snacks.notifier.hide()
      end,
      desc = 'Dismiss All Notifications',
    },
    {
      '<leader>z',
      function()
        Snacks.zen()
      end,
      desc = 'Toggle Zen Mode',
    },
    {
      '<leader>Z',
      function()
        Snacks.zen.zoom()
      end,
      desc = 'Toggle Zoom',
    },
    {
      ']]',
      function()
        Snacks.words.jump(vim.v.count1)
      end,
      desc = 'Next Reference',
      mode = { 'n', 't' },
    },
    {
      '[[',
      function()
        Snacks.words.jump(-vim.v.count1)
      end,
      desc = 'Prev Reference',
      mode = { 'n', 't' },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd

        -- Create some toggle mappings
        Snacks.toggle.option('spell', { name = 'Spelling' }):map('<leader>us')
        Snacks.toggle.option('wrap', { name = 'Wrap' }):map('<leader>uw')
        Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map('<leader>uL')
        Snacks.toggle.diagnostics():map('<leader>ud')
        Snacks.toggle.line_number():map('<leader>ul')
        Snacks.toggle
          .option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
          :map('<leader>uc')
        Snacks.toggle.treesitter():map('<leader>uT')
        Snacks.toggle.inlay_hints():map('<leader>uh')
      end,
    })
  end,
}
