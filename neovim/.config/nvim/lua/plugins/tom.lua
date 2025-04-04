-- My customize config
return {
  -- For Community Plugin
  {
    "catppuccin",
    opts = {
      flavour = "mocha",
      transparent_background = true,
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
}
