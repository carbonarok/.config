return {
  'lervag/vimtex',
  ft = { 'tex', 'latex', 'bib' },
  init = function()
    vim.g.vimtex_view_method = 'skim'
    vim.g.vimtex_compiler_method = 'latexmk'
  end,
}
