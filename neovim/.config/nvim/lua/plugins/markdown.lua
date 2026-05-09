-- Prerequisite:
-- mermaid-cli: mermaid graph preview
-- imageMagick: image preview
-- tectonic: latex preview
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
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
        enabled = false,
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      image = {
        doc = {
          enabled = true,
          inline = false,
          float = true,
          max_width = 80,
          max_height = 40,
          conceal = function(lang, type)
            -- only conceal math expressions
            return type == "math"
          end,
        },
        math = {
          enabled = true,
        },
      },
    },
  },
}
