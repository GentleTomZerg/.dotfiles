-- My customize config
return {
	-- For Community Plugin
	{
		"catppuccin",
		opts = {
			flavour = "mocha",
			transparent_background = true,
		},
	},
	{
		"nvim-jdtls",
		keys = {
			{ "<leader>df", "<cmd> lua require'jdtls'.test_class() <cr>",          desc = "Test all" },
			{ "<leader>dn", "<cmd> lua require'jdtls'.test_nearest_method() <cr>", desc = "Test method" },
		},
	},
	-- For Astro Built-in Plugins
	{
		"nvim-neo-tree/neo-tree.nvim",
		opts = {
			-- neo-tree separator transparent
			source_selector = {
				separator = { left = "", right = "" },
				highlight_tab = "NeoTreeTabInactive",
				highlight_tab_active = "NeoTreeTabActive",
				highlight_background = "NeoTreeTabActive",
				highlight_separator = "NeoTreeTabSeparatorActive",
				highlight_separator_active = "NeoTreeTabSeparatorActive",
			},
			-- neo-tree window
			window = {
				position = "float",
			},
		},
	},
}
