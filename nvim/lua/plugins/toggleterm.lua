return {
  'akinsho/toggleterm.nvim',
  version = '*',
  lazy = false,
  opts = {
    -- We manage visibility ourselves, so no global open_mapping
    -- (prevents accidental opening of "terminal 1" behind the scenes)
    open_mapping = nil,
    shade_terminals = true,
    persist_size = true,
    start_in_insert = true,
    direction = 'horizontal',
    size = 15,
  },
  config = function(_, opts)
    -- Init ToggleTerm
    require('toggleterm').setup(opts)

    local Terminal = require('toggleterm.terminal').Terminal

    -- VSCode-like terminal manager (one visible, others hidden)
    local terms = {} -- array of Terminal objects
    local current = 0 -- 1-based index into `terms` (0 = none selected)
    local seq = 0 -- unique ID counter for ToggleTerm instances

    --------------------------------------------------------------------------
    -- Helpers
    --------------------------------------------------------------------------
    local function hide_all()
      for _, t in ipairs(terms) do
        if t:is_open() then
          pcall(function()
            t:close()
          end) -- close window only (keep job running)
        end
      end
    end

    local function show(i)
      if not terms[i] then
        return
      end
      hide_all()
      -- Ensure the panel opens at the bottom like VSCode
      vim.cmd 'botright' -- hint Neovim where to place the next horizontal window
      terms[i]:open() -- open window for that terminal (job stays the same)
      current = i
    end

    local function is_current_visible()
      if current == 0 or not terms[current] then
        return false
      end
      return terms[current]:is_open()
    end

    --------------------------------------------------------------------------
    -- Actions (VSCode-style)
    --------------------------------------------------------------------------
    local function new_terminal()
      seq = seq + 1
      local term = Terminal:new {
        id = seq,
        direction = 'horizontal',
        start_in_insert = true,
        hidden = true, -- keeps it out of buffer lists
      }
      table.insert(terms, term)
      show(#terms)
    end

    local function toggle_panel()
      if current == 0 or not terms[current] then
        -- No terminal yet → create first one
        new_terminal()
        return
      end
      if is_current_visible() then
        terms[current]:close() -- hide current
      else
        show(current) -- reveal current
      end
    end

    local function next_terminal()
      if #terms == 0 then
        new_terminal()
        return
      end
      local i = current
      if i == 0 then
        i = 1
      else
        i = (i % #terms) + 1
      end
      show(i)
    end

    local function prev_terminal()
      if #terms == 0 then
        new_terminal()
        return
      end
      local i = current
      if i == 0 then
        i = #terms
      else
        i = ((i - 2) % #terms) + 1
      end
      show(i)
    end

    local function kill_current()
      if current == 0 or not terms[current] then
        return
      end
      -- Fully terminate the job/process and remove from list
      pcall(function()
        terms[current]:shutdown()
      end)
      table.remove(terms, current)
      if #terms == 0 then
        current = 0
        return
      end
      -- Show the next available terminal
      if current > #terms then
        current = #terms
      end
      show(current)
    end

    local function kill_all()
      hide_all()
      for i = #terms, 1, -1 do
        pcall(function()
          terms[i]:shutdown()
        end)
        table.remove(terms, i)
      end
      current = 0
    end

    -- Optional: open N terminals quickly (hidden except the last shown)
    local function open_n(n)
      n = tonumber(n) or 1
      for _ = 1, n do
        new_terminal()
      end
    end

    --------------------------------------------------------------------------
    -- Keymaps (VSCode-like)
    --------------------------------------------------------------------------
    -- Toggle panel (show/hide current)
    vim.keymap.set({ 'n', 't' }, '<leader>`', toggle_panel, { desc = 'Toggle terminal panel' })

    -- New terminal (hidden others; only this one visible)
    vim.keymap.set({ 'n', 't' }, '<leader>tn', new_terminal, { desc = 'New terminal (VSCode style)' })

    -- Cycle terminals (like switching terminal tabs)
    vim.keymap.set({ 'n', 't' }, '<leader>tj', next_terminal, { desc = 'Next terminal' })
    vim.keymap.set({ 'n', 't' }, '<leader>tk', prev_terminal, { desc = 'Previous terminal' })

    -- Kill terminals
    vim.keymap.set({ 'n', 't' }, '<leader>tx', kill_current, { desc = 'Kill current terminal' })
    vim.keymap.set({ 'n', 't' }, '<leader>tX', kill_all, { desc = 'Kill ALL terminals' })

    -- Utility: open multiple quickly (e.g., 3)
    vim.keymap.set('n', '<leader>t3', function()
      open_n(3)
    end, { desc = 'Open 3 terminals' })

    --------------------------------------------------------------------------
    -- Terminal-mode QoL (buffer-local; keeps normal-mode keys intact)
    --------------------------------------------------------------------------
    vim.api.nvim_create_autocmd('TermOpen', {
      pattern = 'term://*',
      callback = function()
        local o = { buffer = 0 }
        -- Cleanly exit terminal insert mode
        vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], o)
        -- Move between splits (if you ever split the panel)
        vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], o)
        vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], o)
        vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], o)
        vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], o)
      end,
    })
  end,
}
