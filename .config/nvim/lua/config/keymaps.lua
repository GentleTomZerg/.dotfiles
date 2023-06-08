-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- My keymaps config
-- local Util = require("lazyvim.util")

local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      opts.remap = nil
    end
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

-- insert mode
map("i", "<A-j>", "<Down>", { desc = "move cursor down in insert mode" })
map("i", "<A-k>", "<Up>", { desc = "move cursor up in insert mode" })
map("i", "<A-h>", "<Left>", { desc = "move cursor left in insert mode" })
map("i", "<A-l>", "<Right>", { desc = "move cursor right in insert mode" })
map("i", "ii", "<ESC>", { desc = "press i for two time to normal mode" })
