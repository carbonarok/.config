return {
  {
    'rmagatti/auto-session',
    lazy = false, -- load early so it catches VimEnter/VimLeave
    dependencies = { 'nvim-tree/nvim-web-devicons' }, -- optional
    opts = {
      auto_create = true,
      auto_restore = true,
      auto_save = true,
      git_use_branch_name = true,
      log_level = 'info',
      post_restore_cmds = { 'Neotree show right', 'Neotree reveal' },
      pre_save_cmds = { 'Neotree close' },
      suppressed_dirs = { '~/', '/' },
    },
  },
}
