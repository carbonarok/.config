-- Insert pdb line to current cursor position

local function insert_pdb()
  local line = vim.fn.getline('.')
  local indent = string.match(line, '^%s*')
  local r, _ = unpack(vim.api.nvim_win_get_cursor(0))
  vim.fn.append(r - 1, indent .. '# fmt: on')
  vim.fn.append(r - 1, indent .. 'import pdb; pdb.set_trace()')
  vim.fn.append(r - 1, indent .. '# fmt: off')
end

vim.keymap.set('n', '<leader>pd', insert_pdb, { desc = 'Insert pdb line' })
