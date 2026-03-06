return {
  'folke/flash.nvim',
  enabled = false, -- Temporarily disabled for debugging
  event = 'VeryLazy',
  opts = {
    labels = 'asdfghjklqwertyuiopzxcvbnm',
    search = {
      multi_window = true,
      forward = true,
      wrap = true,
    },
    jump = {
      jumplist = true,
      pos = 'start',
      history = false,
      register = false,
      nohlsearch = false,
      autojump = false,
    },
    label = {
      uppercase = true,
      exclude = '',
      current = true,
      after = true,
      before = false,
      style = 'overlay',
      reuse = 'lowercase',
      rainbow = {
        enabled = false,
        shade = 5,
      },
    },
    modes = {
      search = {
        enabled = true,
        highlight = { backdrop = false },
        jump = { history = true, register = true, nohlsearch = true },
        search = {},
      },
      char = {
        enabled = true,
        config = function(opts)
          opts.autohide = vim.fn.mode(true):find('no') and vim.v.operator == 'y'
          opts.jump_labels = opts.jump_labels
            and vim.v.count == 0
            and vim.fn.reg_executing() == ''
            and vim.fn.reg_recording() == ''
        end,
        autohide = false,
        jump_labels = false,
        multi_line = true,
        label = { exclude = 'hjkliardc' },
        keys = { 'f', 'F', 't', 'T', ';', ',' },
        char_actions = function(motion)
          return {
            [';'] = 'next',
            [','] = 'prev',
            [motion:lower()] = 'next',
            [motion:upper()] = 'prev',
          }
        end,
        search = { wrap = false },
        highlight = { backdrop = true },
        jump = { register = false },
      },
      treesitter = {
        labels = 'abcdefghijklmnopqrstuvwxyz',
        jump = { pos = 'range' },
        search = { incremental = false },
        label = { before = true, after = true, style = 'inline' },
        highlight = { backdrop = false, matches = false },
      },
      treesitter_search = {
        jump = { pos = 'range' },
        search = { multi_window = true, wrap = true, incremental = false },
        remote_op = { restore = true },
        label = { before = true, after = true, style = 'inline' },
      },
      remote = {
        remote_op = { restore = true, motion = true },
      },
    },
    prompt = {
      enabled = true,
      prefix = { { '⚡', 'FlashPromptIcon' } },
      win_config = {
        relative = 'editor',
        width = 1,
        height = 1,
        row = -1,
        col = 0,
        zindex = 1000,
      },
    },
  },
  keys = {
    {
      's',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').jump()
      end,
      desc = 'Flash',
    },
    {
      'S',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').treesitter()
      end,
      desc = 'Flash Treesitter',
    },
    {
      'r',
      mode = 'o',
      function()
        require('flash').remote()
      end,
      desc = 'Remote Flash',
    },
    {
      'R',
      mode = { 'o', 'x' },
      function()
        require('flash').treesitter_search()
      end,
      desc = 'Treesitter Search',
    },
    {
      '<c-s>',
      mode = { 'c' },
      function()
        require('flash').toggle()
      end,
      desc = 'Toggle Flash Search',
    },
  },
}
