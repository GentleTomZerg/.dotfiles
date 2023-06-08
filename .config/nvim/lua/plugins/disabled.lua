return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        -- disable jdtls config from lspconfig
        jdtls = function()
          return true
        end,
      },
    },
  },
}
