return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- use latest release, remove to use latest commit
  event = { "BufReadPre  */Obsidian-Vault/*.md" },
  lazy = true,
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false, -- this will be removed in 4.0.0
    ui = { enable = false },
    workspaces = {
      {
        name = "personal",
        path = "~/Projects/Obsidian-Vault",
      },
    },
  },
}
