-- My customize config
-- For Community Plugin
return {
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
}
