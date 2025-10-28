-- Filetype-specific indentation
local g = vim.api.nvim_create_augroup('ft_indents', { clear = true })

local function set_indent(buf, sw, expand)
  vim.bo[buf].expandtab = expand
  vim.bo[buf].shiftwidth = sw
  vim.bo[buf].tabstop = sw
  vim.bo[buf].softtabstop = expand and sw or 0
end

vim.api.nvim_create_autocmd('FileType', {
  group = g,
  pattern = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'json',
    'jsonc',
    'yaml',
    'yml',
    'html',
    'css',
    'scss',
    'lua',
    'terraform',
    'hcl',
    'markdown',
    'mdx',
    'toml',
  },
  callback = function(ev)
    set_indent(ev.buf, 2, true)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = g,
  pattern = { 'python', 'rust', 'c', 'cpp' }, -- 4 spaces
  callback = function(ev)
    set_indent(ev.buf, 4, true)
  end,
})

-- Special cases:
vim.api.nvim_create_autocmd('FileType', {
  group = g,
  pattern = { 'go' }, -- Go uses real tabs; gofmt/goimports expect tabs
  callback = function(ev)
    vim.bo[ev.buf].expandtab = false
    vim.bo[ev.buf].shiftwidth = 0 -- follow tabstop
    vim.bo[ev.buf].tabstop = 8 -- standard visual width for tabs in Go
    vim.bo[ev.buf].softtabstop = 0
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = g,
  pattern = { 'make', 'makefile' }, -- Makefiles require TABs
  callback = function(ev)
    vim.bo[ev.buf].expandtab = false
    vim.bo[ev.buf].shiftwidth = 0
    vim.bo[ev.buf].tabstop = 8
    vim.bo[ev.buf].softtabstop = 0
  end,
})
