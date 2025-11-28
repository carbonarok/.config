return {
  'mrcjkb/rustaceanvim',
  version = '^6',
  ft = { 'rust' },

  config = function()
    vim.g.rustaceanvim = {
      server = {
        on_attach = function(_, bufnr)
          ---------------------------------------
          -- Hover (Normal + Insert mode)
          ---------------------------------------
          vim.keymap.set('n', 'K', function()
            vim.cmd.RustLsp({ 'hover', 'actions' })
          end, { desc = 'Rust hover/actions', buffer = bufnr })

          vim.keymap.set('i', '<C-k>', function()
            vim.cmd.RustLsp({ 'hover', 'actions' })
          end, { desc = 'Rust hover/actions', buffer = bufnr })

          ---------------------------------------
          -- Explain error
          ---------------------------------------
          vim.keymap.set('n', '<leader>re', function()
            vim.cmd.RustLsp('explainError')
          end, { desc = 'Explain Rust error', buffer = bufnr })

          ---------------------------------------
          -- Expand macro
          ---------------------------------------
          vim.keymap.set('n', '<leader>rm', function()
            vim.cmd.RustLsp('expandMacro')
          end, { desc = 'Expand macro', buffer = bufnr })

          ---------------------------------------
          -- Run tests
          ---------------------------------------
          vim.keymap.set('n', '<leader>rt', function()
            vim.cmd.RustLsp('runTests')
          end, { desc = 'Run Rust tests', buffer = bufnr })

          ---------------------------------------
          -- Code actions
          ---------------------------------------
          vim.keymap.set('n', '<leader>ra', function()
            vim.cmd.RustLsp('codeAction')
          end, { desc = 'Rust code actions', buffer = bufnr })

          ---------------------------------------
          -- Parent module
          ---------------------------------------
          vim.keymap.set('n', '<leader>rp', function()
            vim.cmd.RustLsp('parentModule')
          end, { desc = 'Go to parent module', buffer = bufnr })

          ---------------------------------------
          -- Syntax tree viewer
          ---------------------------------------
          vim.keymap.set('n', '<leader>rs', function()
            vim.cmd.RustLsp('syntaxTree')
          end, { desc = 'View Rust syntax tree', buffer = bufnr })
        end,
      },
    }
  end,
}
