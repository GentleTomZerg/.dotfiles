if vim.g.vscode then
  -- Vscode extension
  require("vscode.keymappings")
  require("vscode.options")
else
  -- bootstrap lazy.vim, LazyVim and your plugins
  require("vscode.options")
end
