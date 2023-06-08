return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    -- lazy = true,
    -- cmd = "NvimTreeToggle",
    -- keys = {
    --   { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explore" },
    -- },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      -- lazy = true,
    },
    config = function()
      require("nvim-tree").setup({})
    end,
  },
}
