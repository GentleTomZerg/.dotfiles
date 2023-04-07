-- Additional Plugins
lvim.plugins = {
  -- Markdown
  {
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    ft = "markdown",
    config = function()
      vim.g.mkdp_auto_start = 1
    end,
  },

  -- Hop (Like Easymotion)
  {
    "phaazon/hop.nvim",
    event = "BufRead",
    config = function()
      require("hop").setup()
    end,
  },
}
