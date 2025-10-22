return {
  'linux-cultist/venv-selector.nvim',
  dependencies = {
    'neovim/nvim-lspconfig',
    { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },
  },
  ft = 'python',
  keys = {
    { ',v', '<cmd>VenvSelect<cr>' },
  },
  opts = {
    options = {},
    search = {
      my_venvs = {
        command = [[bash -lc '
set -e
paths=()

# Prefer Poetry’s configured venv path
if command -v poetry >/dev/null 2>&1; then
  root="$(poetry config virtualenvs.path 2>/dev/null || true)"
  [ -z "$root" ] && [ -d "$HOME/.cache/pypoetry/virtualenvs" ] && root="$HOME/.cache/pypoetry/virtualenvs"
  [ -z "$root" ] && [ -d "$HOME/Library/Caches/pypoetry/virtualenvs" ] && root="$HOME/Library/Caches/pypoetry/virtualenvs"
  [ -n "$root" ] && [ -d "$root" ] && paths+=("$root")
fi

# Also search project-local .venv
[ -d "$PWD/.venv" ] && paths+=("$PWD/.venv")

# Nothing to search? exit quietly.
[ ${#paths[@]} -eq 0 ] && exit 0

# Find python executables (python, python3, python3.x)
if command -v fd >/dev/null 2>&1; then
  fd -a -H -t x "python(3(\.[0-9]+)?)?$" "${paths[@]}"
else
  find "${paths[@]}" -type f -perm -111 -regex ".*/python(3(\.[0-9]+)?)?$"
fi
']],
      },
    },
  },
}
