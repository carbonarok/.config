-- lua/plugins/dap.lua
return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
      'mfussenegger/nvim-dap-python',
    },
    config = function()
      -- --- Core setup (do NOT bind debugpy from Mason) -----------------------
      require('mason').setup()
      require('mason-nvim-dap').setup {
        ensure_installed = {},            -- keep empty so Mason's debugpy won't be preferred
        automatic_installation = false,   -- avoid re-binding adapters
        handlers = {},
      }

      local dap, dapui = require 'dap', require 'dapui'
      dapui.setup()
      require('nvim-dap-virtual-text').setup()

      -- Keep UI open on errors; only close on clean exit.
      dap.listeners.after.event_initialized['dapui'] = function() dapui.open() end
      dap.listeners.before.event_terminated['dapui'] = nil
      dap.listeners.before.event_exited['dapui'] = function() dapui.close() end
      pcall(dap.set_exception_breakpoints, { 'raised', 'uncaught' })

      -- --- Utilities ---------------------------------------------------------
      local function join(a, b) return (a:gsub('/+$','')) .. '/' .. (b:gsub('^/+','')) end
      local function is_exec(p) return p and p ~= '' and vim.fn.executable(p) == 1 end
      local function is_file(p) return p and p ~= '' and vim.fn.filereadable(p) == 1 end
      local function exepath(bin) local p = vim.fn.exepath(bin); return p ~= '' and p or nil end
      local function trim(s) return (s or ''):gsub('%s+$','') end
      local function run(cmd) local ok,out=pcall(vim.fn.systemlist,cmd); if ok and #out>0 then return trim(out[1]) end end

      local function find_project_root(start_dir)
        local dir = vim.fn.fnamemodify(start_dir or vim.fn.getcwd(), ':p')
        local markers = { 'manage.py', 'pyproject.toml', 'setup.cfg', 'setup.py', 'pyproject.toml', '.venv/bin/python' }
        while dir and dir ~= '/' do
          for _, m in ipairs(markers) do
            if is_file(join(dir, m)) or (m:match('python') and is_exec(join(dir,'.venv/bin/python'))) then
              return dir
            end
          end
          dir = vim.fn.fnamemodify(dir, ':h')
        end
        return start_dir or vim.fn.getcwd()
      end

      local function detect_python(root)
        root = root or vim.fn.getcwd()

        -- Local .venv
        local dotvenv = join(root, '.venv/bin/python')
        if is_exec(dotvenv) then return dotvenv end

        -- Poetry (prefer project-local)
        local poetry = exepath('poetry')
        if poetry and is_file(join(root, 'pyproject.toml')) then
          local venv = run({ poetry, '-C', root, 'env', 'info', '-p' }) or run({ poetry, 'env', 'info', '-p' })
          if venv and venv ~= '' and is_exec(join(venv, 'bin/python')) then
            return join(venv, 'bin/python')
          end
        end

        -- Pipenv
        local pipenv = exepath('pipenv')
        if pipenv and is_file(join(root, 'Pipfile')) then
          local venv = run({ pipenv, '--venv' })
          if venv and is_exec(join(venv, 'bin/python')) then return join(venv, 'bin/python') end
        end

        -- direnv / VIRTUAL_ENV
        local venv = os.getenv('VIRTUAL_ENV')
        if venv and is_exec(join(venv, 'bin/python')) then return join(venv, 'bin/python') end

        -- pyenv
        local pyenv = exepath('pyenv')
        if pyenv then
          local p = run({ pyenv, 'which', 'python' })
          if is_exec(p) then return p end
        end

        -- System fallback
        return exepath('python3') or exepath('python') or 'python3'
      end

      local function smart_root_and_python(config)
        -- Look near the program, cwd, and common monorepo subdirs
        local cwd = vim.fn.getcwd()
        local cfg_cwd = config and config.cwd or nil
        local program_dir = (config and config.program) and vim.fn.fnamemodify(config.program, ':p:h') or nil
        local candidates = {
          cfg_cwd,
          program_dir,
          cwd,
          join(cwd, 'backend'),
          join(cwd, 'server'),
          join(cwd, 'api'),
          join(cwd, 'services/backend'),
        }
        for _, base in ipairs(candidates) do
          if base then
            local root = find_project_root(base)
            if root then
              local py = detect_python(root)
              if is_exec(py) then return root, py end
            end
          end
        end
        local root = find_project_root(cwd)
        return root, detect_python(root)
      end

      -- --- One dynamic adapter for everything --------------------------------
      local function dynamic_python_adapter(cb, config)
        local root, py = smart_root_and_python(config)
        -- Ensure PYTHONPATH includes root for `-m fluxus`-style invocations
        config.cwd = config.cwd or root
        config.env = config.env or {}
        if not config.env.PYTHONPATH then
          config.env.PYTHONPATH = root
        elseif not tostring(config.env.PYTHONPATH):find(root, 1, true) then
          config.env.PYTHONPATH = config.env.PYTHONPATH .. ':' .. root
        end

        cb({ type = 'executable', command = py, args = { '-m', 'debugpy.adapter' } })
      end

      -- Force BOTH ids to our dynamic adapter (covers "python" and "debugpy")
      dap.adapters.python  = dynamic_python_adapter
      dap.adapters.debugpy = dynamic_python_adapter

      -- nvim-dap-python helpers (pytest etc.) use the same project venv
      local root = find_project_root()
      local py_helpers = detect_python(root)
      require('dap-python').setup(py_helpers)

      -- Warn if debugpy missing in project interpreter
      do
        local out = vim.fn.system({ py_helpers, '-c', 'import debugpy,sys;sys.stdout.write(debugpy.__version__)' })
        if not tostring(out or ''):match('%d+%.%d+') then
          vim.schedule(function()
            vim.notify(
              ('debugpy not found in %s.\nRun:\n  %s -m pip install -U debugpy'):format(py_helpers, py_helpers),
              vim.log.levels.WARN,
              { title = 'nvim-dap-python' }
            )
          end)
        end
      end

      -- --- Baseline Python configs -------------------------------------------
      local function django_config()
        local cwd = vim.fn.getcwd()
        local manage = is_file(join(cwd, 'manage.py')) and join(cwd, 'manage.py')
          or (is_file(join(cwd, 'backend/manage.py')) and join(cwd, 'backend/manage.py'))
          or nil
        if not manage then return nil end
        local proj_dir = vim.fn.fnamemodify(manage, ':p:h')
        return {
          type = 'python',
          request = 'launch',
          name = 'Django runserver',
          program = manage,
          args = { 'runserver', '0.0.0.0:8000' },
          django = true,
          cwd = proj_dir,
          console = 'integratedTerminal',
          justMyCode = false,
          env = { PYTHONPATH = proj_dir },
        }
      end

      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = 'Launch current file',
          program = '${file}',
          console = 'integratedTerminal',
          justMyCode = false,
          cwd = '${workspaceFolder}',
        },
        {
          type = 'python',
          request = 'attach',
          name = 'Attach to process',
          processId = require('dap.utils').pick_process,
          justMyCode = false,
        },
        django_config(),
      }

      -- --- Load VSCode launch.json and normalize entries ---------------------
      local function normalize_python_configs()
        local configs = dap.configurations.python or {}
        for _, cfg in ipairs(configs) do
          -- Force adapter id to one we control
          if cfg.type == 'debugpy' then cfg.type = 'python' end

          -- Ensure CWD and PYTHONPATH are sane for module/package runs
          local root2 = find_project_root(cfg.cwd or vim.fn.getcwd())
          cfg.cwd = cfg.cwd or root2
          cfg.env = cfg.env or {}
          if not cfg.env.PYTHONPATH then
            cfg.env.PYTHONPATH = root2
          elseif not tostring(cfg.env.PYTHONPATH):find(root2, 1, true) then
            cfg.env.PYTHONPATH = cfg.env.PYTHONPATH .. ':' .. root2
          end

          -- Prefer integrated terminal for visibility
          cfg.console = cfg.console or 'integratedTerminal'
        end
      end

      do
        local vscode = require('dap.ext.vscode')
        local launchjs = vim.fn.getcwd() .. '/.vscode/launch.json'
        if vim.fn.filereadable(launchjs) == 1 then
          -- Map both "python" and "debugpy" types to Python configs we control.
          vscode.load_launchjs(launchjs, { python = { 'python' }, debugpy = { 'python' } })
        end
        normalize_python_configs()
      end

      -- --- Keymaps (unchanged) -----------------------------------------------
      local map = vim.keymap.set
      map('n', '<F5>', dap.continue, { desc = 'DAP Continue/Start' })
      map('n', '<F9>', dap.toggle_breakpoint, { desc = 'DAP Toggle Breakpoint' })
      map('n', '<F10>', dap.step_over, { desc = 'DAP Step Over' })
      map('n', '<F11>', dap.step_into, { desc = 'DAP Step Into' })
      map('n', '<F12>', dap.step_out, { desc = 'DAP Step Out' })
      map('n', '<leader>db', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = 'DAP Conditional BP' })
      map('n', '<leader>dr', dap.repl.open, { desc = 'DAP REPL' })
      map({ 'n', 'v' }, '<leader>de', function() require('dap.ui.widgets').hover() end, { desc = 'DAP Eval (hover)' })

      local dappython = require('dap-python')
      map('n', '<leader>tm', dappython.test_method, { desc = 'Debug Pytest Method' })
      map('n', '<leader>tc', dappython.test_class,  { desc = 'Debug Pytest Class' })
      map('v', '<leader>ts', dappython.debug_selection, { desc = 'Debug Selection' })
    end,
  },
}
