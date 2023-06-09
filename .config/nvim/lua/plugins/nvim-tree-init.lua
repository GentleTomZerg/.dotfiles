return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explore" },
    },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({})
    end,
  },
}
