return {
	"supermaven-inc/supermaven-nvim",
	config = function()
		require("supermaven-nvim").setup({})
		vim.cmd.SuperMavenUseFree()
	end,
}
