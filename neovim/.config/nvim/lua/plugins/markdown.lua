return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = "markdown",
  lazy = true,
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" }, -- if you use standalone mini plugins
  -- dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" }, -- if you use the mini.nvim suite
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  specs = {
    {
      "AstroNvim/astrocore",
      optional = true,
      ---@type AstroCoreOpts
      opts = {
        treesitter = { ensure_installed = { "html", "markdown", "markdown_inline", "latex" } },
      },
    },
  },
  opts = {
    latex = {
      enabled = true,
      render_modes = false,
      converter = { "utftex", "latex2text" },
      highlight = "RenderMarkdownMath",
      position = "center",
      top_pad = 0,
      bottom_pad = 0,
    },
  },
}
