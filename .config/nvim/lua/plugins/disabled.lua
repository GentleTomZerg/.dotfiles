return {
  -- disable jdtls of nvim-lspconfig
  -- thus nvim-jdtls will be the only lsp for java
  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        jdtls = function()
          return true
        end,
      },
    },
  },

  -- neo-tree is not powerful enough
  -- use nvim-tree instead
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },

  {
    "folke/tokyonight.nvim",
    enabled = false,
  },
}
