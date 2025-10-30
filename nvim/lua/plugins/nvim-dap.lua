-- lua/plugins/dap.lua
return {
  {
    'mfussenegger/nvim-dap',
    event = 'VeryLazy',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'ravenxrz/DAPInstall.nvim', -- provides `dap-install`
      'suketa/nvim-dap-ruby',
      'nvim-telescope/telescope.nvim',
      'nvim-telescope/telescope-dap.nvim',
      'nvim-neotest/nvim-nio',
      { 'scalameta/nvim-metals', optional = true },
      'mfussenegger/nvim-dap-python',
    },
    keys = {
      {
        '<leader>dc',
        function()
          require('dap').continue()
        end,
        desc = 'DAP Continue',
      },
      {
        '<leader>drr',
        function()
          require('dap').restart()
        end,
        desc = 'DAP Restart',
      },
      {
        '<leader>do',
        function()
          require('dap').step_over()
        end,
        desc = 'DAP Step Over',
      },
      {
        '<leader>di',
        function()
          require('dap').step_into()
        end,
        desc = 'DAP Step Into',
      },
      {
        '<leader>dx',
        function()
          require('dap').step_out()
        end,
        desc = 'DAP Step Out',
      },
      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'DAP Toggle Breakpoint',
      },
      {
        '<leader>dB',
        function()
          require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
        end,
        desc = 'DAP Conditional Breakpoint',
      },
      {
        '<leader>dl',
        function()
          require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
        end,
        desc = 'DAP Logpoint',
      },
      {
        '<leader>dr',
        function()
          require('dap').repl.open()
        end,
        desc = 'DAP REPL',
      },
      {
        '<leader>drl',
        function()
          require('dap').run_last()
        end,
        desc = 'DAP Run Last',
      },
      {
        '<leader>dev',
        function()
          require('dapui').eval()
        end,
        desc = 'DAP UI Eval',
      },
      {
        '<leader>dclose',
        function()
          require('dapui').close()
        end,
        desc = 'DAP UI Close',
      },
      {
        '<leader>de',
        function()
          require('dap').close()
        end,
        desc = 'DAP Close',
      },
      {
        '<leader>dev',
        function()
          require('dapui').eval()
        end,
        mode = 'v',
        desc = 'DAP UI Eval (Visual)',
      },
    },
    config = function()
      local dap, dapui = require('dap'), require('dapui')

      -- UI + virtual text
      dapui.setup({
        expand_lines = true,
        controls = { enabled = true, element = 'repl' },
        icons = { collapsed = '', current_frame = '', expanded = '' },
        mappings = {
          -- Make Neo-tree style:
          expand = { 'l', '<CR>', '<2-LeftMouse>' }, -- open/expand node
          toggle = 'h', -- collapse/expand (acts as 'close' when open)
          open = 'o', -- keep default
          remove = 'd',
          edit = 'e',
          repl = 'r',
        },
        layouts = {
          {
            -- LEFT column: never touches the right where Neo-tree lives
            elements = {
              { id = 'scopes', size = 0.60 },
              { id = 'stacks', size = 0.25 },
              { id = 'breakpoints', size = 0.15 },
              -- { id = 'watches', size = 0.15 },
            },
            size = 40, -- columns
            position = 'left',
          },
          {
            -- BOTTOM strip for REPL + Console
            elements = {
              { id = 'repl', size = 1 },
              -- { id = 'console', size = 0.45 },
            },
            size = 12, -- rows
            position = 'bottom',
          },
        },
        floating = {
          max_height = 0.85,
          max_width = 0.85,
          border = 'rounded',
          mappings = { close = { 'q', '<Esc>' } },
        },
        render = { max_type_length = 60 },
      })
      require('nvim-dap-virtual-text').setup()

      -- dap-install setup + auto-configure installed debuggers
      local dap_install = require('dap-install')
      dap_install.setup({
        installation_path = vim.fn.stdpath('data') .. '/dapinstall/',
        verbosely_call_debuggers = true,
      })
      local dbg_list = require('dap-install.api.debuggers').get_installed_debuggers()
      for _, debugger in ipairs(dbg_list) do
        dap_install.config(debugger)
      end

      -----------------------------------------------------------------------
      -- Python: auto-detect venv python & configure nvim-dap-python/debugpy
      -----------------------------------------------------------------------
      local function path_join(...)
        return table.concat({ ... }, '/')
      end

      local function file_exists(p)
        return p and vim.uv.fs_stat(p) ~= nil
      end

      local function exepath(bin)
        local p = vim.fn.exepath(bin)
        if p == nil or p == '' then
          return nil
        end
        return p
      end

      local function workspace_root()
        -- Prefer LSP root if available; else use current working directory.
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        for _, c in ipairs(clients) do
          if c.config and c.config.root_dir then
            return c.config.root_dir
          end
        end
        return vim.loop.cwd()
      end

      local function detect_python()
        -- 0) Allow user override via global
        if type(_G.venv_python_path) == 'function' then
          local p = _G.venv_python_path()
          if file_exists(p) then
            return p
          end
        elseif type(_G.venv_python_path) == 'string' and file_exists(_G.venv_python_path) then
          return _G.venv_python_path
        end

        -- 1) Activated VIRTUAL_ENV
        local venv = vim.env.VIRTUAL_ENV
        if venv and venv ~= '' then
          local p = path_join(venv, 'bin', 'python')
          if file_exists(p) then
            return p
          end
        end

        -- 2) .venv/ or venv/ in project
        local root = workspace_root()
        for _, name in ipairs({ '.venv', 'venv' }) do
          local p = path_join(root, name, 'bin', 'python')
          if file_exists(p) then
            return p
          end
        end

        -- 3) Poetry-managed env
        if exepath('poetry') and file_exists(path_join(root, 'pyproject.toml')) then
          local out = vim.fn.systemlist({ 'poetry', 'env', 'info', '-p' })
          if out and out[1] and out[1] ~= '' then
            local p = path_join(out[1], 'bin', 'python')
            if file_exists(p) then
              return p
            end
          end
        end

        -- 4) Pipenv (fallback to pipenv --py)
        if exepath('pipenv') and file_exists(path_join(root, 'Pipfile')) then
          local py = vim.fn.systemlist({ 'pipenv', '--py' })[1]
          if py and file_exists(py) then
            return py
          end
        end

        -- 5) pyenv "which python"
        if exepath('pyenv') then
          local py = vim.fn.systemlist({ 'pyenv', 'which', 'python' })[1]
          if py and file_exists(py) then
            return py
          end
        end

        -- 6) System python3 / python
        return exepath('python3') or exepath('python') or 'python3'
      end

      local python_path = detect_python()

      -- Configure adapter via nvim-dap-python
      local dap_python = require('dap-python')
      dap_python.setup(python_path) -- uses "<python> -m debugpy.adapter" internally

      -- Optional: ensure debugpy present in that interpreter (silent, non-blocking)
      local function ensure_debugpy(python)
        if not python or python == '' then
          return
        end
        -- quick check; if missing, install quietly
        vim.fn.jobstart({ python, '-c', 'import debugpy' }, {
          on_exit = function(_, code)
            if code ~= 0 then
              vim.notify('[dap] Installing debugpy into ' .. python .. ' venv…', vim.log.levels.INFO)
              vim.fn.jobstart({ python, '-m', 'pip', 'install', '-q', 'debugpy' }, {
                on_exit = function(_, c)
                  if c == 0 then
                    vim.notify('[dap] debugpy installed.', vim.log.levels.INFO)
                  else
                    vim.notify(
                      '[dap] Failed to install debugpy; install it manually in your venv.',
                      vim.log.levels.WARN
                    )
                  end
                end,
              })
            end
          end,
        })
      end
      ensure_debugpy(python_path)

      -- Handy command to switch the Python on the fly:
      vim.api.nvim_create_user_command('DapUsePython', function(opts)
        local new_py = opts.args ~= '' and opts.args or vim.fn.input('Path to python: ', python_path)
        if new_py ~= '' and file_exists(new_py) then
          python_path = new_py
          dap_python.setup(python_path)
          vim.notify('[dap] Python set to: ' .. python_path, vim.log.levels.INFO)
        else
          vim.notify('[dap] Invalid python: ' .. new_py, vim.log.levels.ERROR)
        end
      end, { nargs = '?', complete = 'file' })

      -- Language adapters
      require('dap-ruby').setup()

      -- Open DAP UI on start
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end

      -- Python launch configs (edit to taste)
      dap.configurations.python = dap.configurations.python or {}
      local function py_cfg_base()
        return {
          type = 'python',
          request = 'launch',
          justMyCode = false,
          console = 'integratedTerminal',
          env = {
            PYTHONFAULTHANDLER = '1',
          },
          pythonPath = function()
            return python_path
          end,
        }
      end

      local ns = vim.api.nvim_create_namespace('dap-traceback')

      vim.api.nvim_set_hl(0, 'DapTracebackBG', { bg = '#3f0000', fg = '#ffcccc' })

      local function clear_tb()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) then
            vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
          end
        end
      end

      dap.listeners.before.event_continued['dap-tb-clear'] = clear_tb
      dap.listeners.before.event_terminated['dap-tb-clear'] = clear_tb
      dap.listeners.before.event_exited['dap-tb-clear'] = clear_tb

      dap.listeners.after.event_stopped['dap-tb-show'] = function(session, body)
        if not body or body.reason ~= 'exception' then
          return
        end

        -- Where did we stop?
        session:request('stackTrace', { threadId = body.threadId, startFrame = 0, levels = 1 }, function(err, resp)
          if err or not resp or not resp.stackFrames or not resp.stackFrames[1] then
            return
          end
          local frame = resp.stackFrames[1]
          local bufnr = vim.fn.bufnr(frame.source and frame.source.path or '')
          if bufnr == -1 then
            bufnr = vim.api.nvim_get_current_buf()
          end
          local line0 = (frame.line or 1) - 1 -- 0-indexed

          -- Ask debugpy for full exception details (including traceback text)
          session:request('exceptionInfo', { threadId = body.threadId }, function(e2, info)
            if e2 or not info or not info.details then
              return
            end

            local parts = {}

            if info.details.message and info.details.message ~= '' then
              table.insert(parts, info.details.message)
            end
            if info.details.stackTrace and info.details.stackTrace ~= '' then
              vim.list_extend(parts, vim.split(info.details.stackTrace, '\n', { plain = true, trimempty = true }))
            end
            if #parts == 0 then
              parts = { 'Exception occurred (no details provided by adapter)' }
            end

            -- Build virtual lines with full-width red background
            vim.schedule(function()
              if not vim.api.nvim_buf_is_loaded(bufnr) then
                return
              end
              local winid = vim.fn.bufwinid(bufnr)
              if winid == -1 then
                winid = vim.api.nvim_get_current_win()
              end
              local width = vim.api.nvim_win_get_width(winid)

              local function pad(line)
                -- Pad to window width so bg covers the whole row
                local display = vim.fn.strdisplaywidth(line)
                local nspace = math.max(0, width - display)
                return line .. string.rep(' ', nspace)
              end

              -- First an empty spacer line to "create space"
              local virt_lines = { { { pad(''), 'DapTracebackBG' } } }
              -- Then the traceback lines
              for _, txt in ipairs(parts) do
                table.insert(virt_lines, { { pad(txt), 'DapTracebackBG' } })
              end

              -- Place the block directly under the faulting line
              -- virt_lines_above=false => below the extmark
              vim.api.nvim_buf_set_extmark(bufnr, ns, line0, 0, {
                virt_lines = virt_lines,
                virt_lines_above = false,
                hl_mode = 'combine',
              })
            end)
          end)
        end)
      end

      -- Example: Django runserver (expects manage.py in project)
      -- table.insert(
      --   dap.configurations.python,
      --   vim.tbl_deep_extend('force', py_cfg_base(), {
      --     name = 'Django: runserver',
      --     program = '${workspaceFolder}/manage.py',
      --     args = { 'runserver', '0.0.0.0:8000' },
      --     cwd = '${workspaceFolder}',
      --   })
      -- )
      --
      -- -- Example: Celery worker via module
      -- table.insert(
      --   dap.configurations.python,
      --   vim.tbl_deep_extend('force', py_cfg_base(), {
      --     name = 'Celery worker',
      --     module = 'celery',
      --     args = { '-A', 'core', 'worker', '-l', 'INFO', '--pool', 'solo', '--concurrency', '1' },
      --     cwd = '${workspaceFolder}',
      --     env = { PYTHONUNBUFFERED = '1' },
      --   })
      -- )

      -- Telescope extensions (ignore if not installed)
      pcall(function()
        require('telescope').load_extension('dap')
      end)
      pcall(function()
        require('telescope').load_extension('metals')
      end)
    end,
  },
}
