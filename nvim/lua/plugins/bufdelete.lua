return {
  'famiu/bufdelete.nvim',
  keys = {
    { '<leader>bb', '<cmd>Bdelete<CR>', desc = 'Delete buffer' },
    { '<leader>bB', '<cmd>Bdelete!<CR>', desc = 'Force delete buffer' },
    { '<leader>bw', '<cmd>Bwipeout<CR>', desc = 'Wipeout buffer' },
    { '<leader>bW', '<cmd>Bwipeout!<CR>', desc = 'Force wipeout buffer' },
  },
}
