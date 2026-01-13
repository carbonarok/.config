return {
  {
    'mizisu/django.nvim',
    dependencies = {
      { 'folke/snacks.nvim' },

      -- This is the important part: extend blink's opts, don't replace them
      {
        'saghen/blink.cmp',
        optional = true,
        opts = function(_, opts)
          opts.sources = opts.sources or {}
          opts.sources.providers = opts.sources.providers or {}

          -- add provider
          opts.sources.providers.django = {
            name = 'Django',
            module = 'django.completions.blink',
            async = true,
            -- score_offset = 100, -- optional
          }

          -- add to default sources (append, don't overwrite)
          local defaults = opts.sources.default or { 'lsp', 'path', 'snippets' }
          if type(defaults) == 'table' then
            local seen = {}
            for _, v in ipairs(defaults) do
              seen[v] = true
            end
            if not seen['django'] then
              table.insert(defaults, 'django')
            end
          end
          opts.sources.default = defaults

          return opts
        end,
      },
    },

    config = function()
      require('django').setup({
        -- your django.nvim config here
      })
    end,
  },
}
