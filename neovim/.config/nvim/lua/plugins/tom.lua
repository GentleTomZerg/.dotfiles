-- My customize config
return {
  -- For Community Plugin
  {
    "catppuccin/nvim",
    opts = {
      flavour = "macchiato",
      -- NOTE: this makes StatusLine transparent (bg = NONE), and AstroNvim derives the
      -- mode chip text colour from StatusLine.bg. That's why `status.colors.mode_fg`
      -- is set explicitly in the AstroNvim/astroui spec further down.
      transparent_background = true,
    },
  },

  {
    "xiyaowong/transparent.nvim",
    opts = {
      extra_groups = {
        "NormalFloat", -- plugins which have float panel such as Lazy, Mason, LspInfo
        "NvimTreeNormal", -- NvimTree
        "FloatBorder",
        "TabLine",
        "TabLineFill",
        "TabLineSel",
      },
    },
  },
  -- For Astro Built-in Plugins
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
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
      -- window = {
      -- 	position = "float",
      -- },
    },
  },

  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = table.concat({
            "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
            "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
            "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
            "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
            "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
            "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
          }, "\n"),
        },
      },
    },
  },

  --- Astroui plugin
  ---@type LazySpec
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      -- change colorscheme
      colorscheme = "catppuccin-nvim",
      -- The statusline is transparent, so AstroNvim's default `mode_fg = StatusLine.bg`
      -- resolves to NONE and the mode chip text falls back to the default fg (near
      -- white) -> ~1:1 contrast on the pastel chips. Set the ink explicitly instead.
      status = {
        colors = {
          mode_fg = "#24273a", -- macchiato base: ink for the pastel mode chips
          inactive = "#8087a2", -- macchiato overlay1: chip bg for PROMPT/CONFIRM/SHELL modes
        },
      },
    },
  },

  --- Astrocore plugin
  ---@type LazySpec
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      -- Configure core features of AstroNvim
      features = {
        large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
        autopairs = true, -- enable autopairs at start
        cmp = true, -- enable completion at start
        diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
        highlighturl = true, -- highlight URLs at start
        notifications = true, -- enable notifications at start
      },
      -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
      diagnostics = {
        virtual_text = true,
        underline = true,
      },
      -- vim options can be configured here
      options = {
        opt = { -- vim.opt.<key>
          relativenumber = true, -- sets vim.opt.relativenumber
          number = true, -- sets vim.opt.number
          spell = false, -- sets vim.opt.spell
          signcolumn = "yes", -- sets vim.opt.signcolumn to yes
          wrap = false, -- sets vim.opt.wrap
        },
        g = { -- vim.g.<key>
          -- configure global vim variables (vim.g)
          -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
          -- This can be found in the `lua/lazy_setup.lua` file
        },
      },
      -- Mappings can be configured through AstroCore as well.
      -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
      mappings = {
        -- first key is the mode
        n = {
          -- second key is the lefthand side of the map

          -- navigate buffer tabs
          ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
          ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
          ["L"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
          ["H"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

          -- mappings seen under group name "Buffer"
          ["<Leader>bd"] = {
            function()
              require("astroui.status.heirline").buffer_picker(
                function(bufnr) require("astrocore.buffer").close(bufnr) end
              )
            end,
            desc = "Close buffer from tabline",
          },
        },
        i = {
          -- smart insert semicolon
          [";;"] = { "<C-o>A;" },
        },
      },
    },
  },
}
