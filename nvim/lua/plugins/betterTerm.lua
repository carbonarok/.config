return {
  'CRAG666/betterTerm.nvim',

  keys = {
    {
      mode = { 'n', 't' },
      '<C-;>',
      function()
        require('betterTerm').open()
      end,
      desc = 'Open BetterTerm 0',
    },
    {
      mode = { 'n', 't' },
      '<C-/>',
      function()
        require('betterTerm').open(1)
      end,
      desc = 'Open BetterTerm 1',
    },
    {
      mode = { 'n' },
      '<leader>tt',
      function()
        require('betterTerm').open(1)
      end,
      desc = 'Open BetterTerm 1',
    },
  },

  opts = {
    size = 20,
    jump_tab_mapping = '<A-$tab>',
  },

  config = function(_, opts)
    local betterTerm = require('betterTerm')
    betterTerm.setup(opts)

    -- Helper: scroll current window of this buffer to bottom
    local function scroll_to_bottom(bufnr)
      bufnr = bufnr or vim.api.nvim_get_current_buf()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      local last = vim.api.nvim_buf_line_count(bufnr)
      -- if we're already near the bottom, keep following output
      local row = vim.api.nvim_win_get_cursor(0)[1]
      if row >= last - 1 then
        pcall(vim.api.nvim_win_set_cursor, 0, { last, 0 })
      end
    end

    -- When a terminal opens, set large scrollback and jump to bottom
    vim.api.nvim_create_autocmd('TermOpen', {
      pattern = 'term://*',
      callback = function(args)
        vim.opt_local.scrollback = 10000

        vim.schedule(function()
          scroll_to_bottom(args.buf)
        end)
      end,
    })

    -- When you enter a terminal window again, snap to bottom
    vim.api.nvim_create_autocmd('TermEnter', {
      pattern = 'term://*',
      callback = function(args)
        vim.schedule(function()
          scroll_to_bottom(args.buf)
        end)
      end,
    })
  end,
}
