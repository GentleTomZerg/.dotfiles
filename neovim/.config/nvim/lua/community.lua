-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
	"AstroNvim/astrocommunity",
	-- colorscheme
	{ import = "astrocommunity.colorscheme.catppuccin" },
	-- Language Packs
	{ import = "astrocommunity.pack.java" },
	{ import = "astrocommunity.pack.lua" },
	{ import = "astrocommunity.pack.markdown" },
	{ import = "astrocommunity.pack.cpp" },
	{ import = "astrocommunity.pack.html-css" },
	{ import = "astrocommunity.pack.bash" },
	{ import = "astrocommunity.pack.vue" },
	{ import = "astrocommunity.pack.python" },
	-- { import = "astrocommunity.pack.nvchad-ui" },

	-- markdown preview
	{ import = "astrocommunity.markdown-and-latex.markdown-preview-nvim" },
	-- color display
	{ import = "astrocommunity.color.nvim-highlight-colors" },
}
