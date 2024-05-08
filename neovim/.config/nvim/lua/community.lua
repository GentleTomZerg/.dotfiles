-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- colorscheme
  { import = "astrocommunity.colorscheme.catppuccin" },
  {
    "catppuccin",
    opts = {
      flavour = "mocha",
      transparent_background = true,
    },
  },

  -- Language Packs
  { import = "astrocommunity.pack.java" },
  {
    "nvim-jdtls",
    keys = {
      { "<leader>df", "<cmd> lua require'jdtls'.test_class() <cr>", desc = "Test all" },
      { "<leader>dn", "<cmd> lua require'jdtls'.test_nearest_method() <cr>", desc = "Test method" },
    },
  },

  { import = "astrocommunity.pack.lua" },

  { import = "astrocommunity.pack.markdown" },

  { import = "astrocommunity.pack.cpp" },
  { import = "astrocommunity.pack.html-css" },
}
