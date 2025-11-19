return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  -- keys = {
  --   {
  --     '<leader>f',
  --     function()
  --       require('conform').format({ async = true, lsp_format = 'fallback' })
  --     end,
  --     mode = '',
  --     desc = '[F]ormat buffer',
  --   },
  -- },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 500,
          lsp_format = 'fallback',
        }
      end
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'black' },
      rust = { 'rustfmt' },
      javascript = { 'prettier' },
      javascriptreact = { 'prettier' },
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },
      css = { 'prettier' },
      scss = { 'prettier' },
      less = { 'prettier' },
      json = { 'prettier' },
      graphql = { 'prettier' },
      html = { 'prettier' },
      vue = { 'prettier' },
      svelte = { 'prettier' },
      yaml = { 'prettier' },
      markdown = { 'prettier' },
      markdown_inline = { 'prettier' },
      dockerfile = { 'prettier' },
      terraform = { 'terraform_fmt' },
      tf = { 'terraform_fmt' },
      proto = { 'buf' },
      proto3 = { 'buf' },
      gql = { 'buf' },
      gql2 = { 'buf' },
      go = { 'buf' },
      sh = { 'shfmt' },
      bash = { 'shfmt' },
      zsh = { 'shfmt' },
      fish = { 'shfmt' },
      vim = { 'vimfmt' },
    },
  },
}
