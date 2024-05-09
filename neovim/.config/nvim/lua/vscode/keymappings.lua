local api = require("vscode.api")
-- https://vi.stackexchange.com/a/31887
local nv_keymap = function(lhs, rhs)
	vim.api.nvim_set_keymap("n", lhs, rhs, { noremap = true, silent = true })
	vim.api.nvim_set_keymap("v", lhs, rhs, { noremap = true, silent = true })
end

local nx_keymap = function(lhs, rhs)
	vim.api.nvim_set_keymap("n", lhs, rhs, { silent = true })
	vim.api.nvim_set_keymap("v", lhs, rhs, { silent = true })
end

--#region keymap
vim.keymap.set({ "n" }, "<leader><cr>", "<cmd>source $MYVIMRC<cr>")
-- #General Mappings
vim.g.mapleader = " "
vim.keymap.set({ "n" }, "<leader>n", api.file.new)
vim.keymap.set({ "n" }, "<leader>w", api.file.save)
vim.keymap.set({ "n" }, "<leader>c", api.editor.closeActive)
vim.keymap.set({ "n" }, "[t", api.workbench.previousEditor)
vim.keymap.set({ "n" }, "]t", api.workbench.nextEditor)
vim.keymap.set({ "n", "v" }, "<leader>/", api.comment.selected)
vim.keymap.set({ "n", "v" }, "H", api.workbench.previousEditor)
vim.keymap.set({ "n", "v" }, "L", api.workbench.nextEditor)

-- #Explorer
vim.keymap.set({ "n", "v" }, "<leader>e", api.workbench.focusExplorer)
vim.keymap.set({ "n", "v" }, "<leader>o", api.workbench.revealInExplorer)

-- #LSP
vim.keymap.set({ "n" }, "<leader>lr", api.lsp.rename)
vim.keymap.set({ "n" }, "<leader>ls", api.lsp.showSymbols)
vim.keymap.set({ "n" }, "gI", api.lsp.goImpl)
vim.keymap.set({ "n" }, "gr", api.lsp.goRef)

nv_keymap("<leader>h", "^")
nv_keymap("<leader>l", "$")
nv_keymap("<leader>a", "%")
nx_keymap("j", "gj")
nx_keymap("k", "gk")

-- vim.keymap.set({ 'n', 'v' }, "<leader>", whichkey.show)

-- vim.keymap.set({ 'n' }, "<leader>i", editor.organizeImport)

-- no highlight
-- vim.keymap.set({ 'n' }, "<leader>n", "<cmd>noh<cr>")

-- vim.keymap.set({ 'n', 'v' }, "<leader> ", workbench.showCommands)

-- -- error
-- vim.keymap.set({ 'n' }, "<leader>el", error.list)
-- vim.keymap.set({ 'n' }, "<leader>en", error.next)
-- vim.keymap.set({ 'n' }, "<leader>ep", error.previous)

-- git
-- vim.keymap.set({ 'n' }, "<leader>gb", git.switch)
-- vim.keymap.set({ 'n' }, "<leader>gi", git.init)
-- vim.keymap.set({ 'n' }, "<leader>gd", git.deleteBranch)
-- vim.keymap.set({ 'n' }, "<leader>gf", git.fetch)
-- vim.keymap.set({ 'n' }, "<leader>gs", git.status)
-- vim.keymap.set({ 'n' }, "<leader>gp", git.pull)
-- vim.keymap.set({ 'n' }, "<leader>gg", git.graph)

-- -- project
-- vim.keymap.set({ 'n' }, "<leader>pf", project.findFile)
-- vim.keymap.set({ 'n' }, "<leader>pp", project.switch)
-- vim.keymap.set({ 'n' }, "<leader>pt", project.tree)

-- -- file
-- vim.keymap.set({ 'n', 'v' }, "<space>w", file.save)
-- vim.keymap.set({ 'n', 'v' }, "<space>wa", file.saveAll)
-- vim.keymap.set({ 'n', 'v' }, "<space>fs", file.save)
-- vim.keymap.set({ 'n', 'v' }, "<space>fS", file.saveAll)
-- vim.keymap.set({ 'n' }, "<space>ff", file.format)
-- vim.keymap.set({ 'n' }, "<space>fn", file.new)
-- vim.keymap.set({ 'n' }, "<space>ft", file.showInExplorer)
-- vim.keymap.set({ 'n' }, "<space>fr", file.rename)

-- -- buffer/editor
-- vim.keymap.set({ 'n', 'v' }, "<space>c", editor.closeActive)
-- vim.keymap.set({ 'n', 'v' }, "<space>bc", editor.closeActive)
-- vim.keymap.set({ 'n', 'v' }, "<space>k", editor.closeOther)
-- vim.keymap.set({ 'n', 'v' }, "<space>bk", editor.closeOther)

-- -- toggle
-- vim.keymap.set({ 'n', 'v' }, "<leader>ta", toggle.toggleActivityBar)
-- vim.keymap.set({ 'n', 'v' }, "<leader>tz", toggle.toggleZenMode)
-- vim.keymap.set({ 'n', 'v' }, "<leader>ts", toggle.toggleSideBarVisibility)
-- vim.keymap.set({ 'n', 'v' }, "<leader>tt", toggle.theme)

-- -- refactor
-- vim.keymap.set({ 'v' }, "<leader>r", refactor.showMenu)
-- vim.keymap.set({ 'n' }, "<leader>rr", symbol.rename)
-- vim.api.nvim_set_keymap('n', '<leader>rd', 'V%d', { silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>rv', 'V%', { silent = true })

-- -- bookmark
-- vim.keymap.set({ 'n' }, "<leader>m", bookmark.toggle)
-- vim.keymap.set({ 'n' }, "<leader>mt", bookmark.toggle)
-- vim.keymap.set({ 'n' }, "<leader>ml", bookmark.list)
-- vim.keymap.set({ 'n' }, "<leader>mn", bookmark.next)
-- vim.keymap.set({ 'n' }, "<leader>mp", bookmark.previous)

-- vim.keymap.set({ 'n' }, "<leader>sr", search.reference)
-- vim.keymap.set({ 'n' }, "<leader>sR", search.referenceInSideBar)
-- vim.keymap.set({ 'n' }, "<leader>sp", search.project)
-- vim.keymap.set({ 'n' }, "<leader>st", search.text)

-- -- vscode
-- vim.keymap.set({ 'n' }, "<leader>ve", vscode.focusEditor)
-- vim.keymap.set({ 'n' }, "<leader>vl", vscode.moveSideBarLeft)
-- vim.keymap.set({ 'n' }, "<leader>vr", vscode.moveSideBarRight)

-- --folding
-- vim.keymap.set({ 'n' }, "<leader>zr", fold.openAll)
-- vim.keymap.set({ 'n' }, "<leader>zO", fold.openRecursive)
-- vim.keymap.set({ 'n' }, "<leader>zo", fold.open)
-- vim.keymap.set({ 'n' }, "<leader>zm", fold.all)
-- vim.keymap.set({ 'n' }, "<leader>zb", fold.blockComment)
-- vim.keymap.set({ 'n' }, "<leader>zc", fold.close)
-- vim.keymap.set({ 'n' }, "<leader>zg", fold.allMarkerRegion)
-- vim.keymap.set({ 'n' }, "<leader>zG", fold.openAllMarkerRegion)
-- vim.keymap.set({ 'n' }, "<leader>za", fold.toggle)

-- vim.keymap.set({ 'n' }, "zr", fold.openAll)
-- vim.keymap.set({ 'n' }, "zO", fold.openRecursive)
-- vim.keymap.set({ 'n' }, "zo", fold.open)
-- vim.keymap.set({ 'n' }, "zm", fold.all)
-- vim.keymap.set({ 'n' }, "zb", fold.blockComment)
-- vim.keymap.set({ 'n' }, "zc", fold.close)
-- vim.keymap.set({ 'n' }, "zg", fold.allMarkerRegion)
-- vim.keymap.set({ 'n' }, "zG", fold.openAllMarkerRegion)
-- vim.keymap.set({ 'n' }, "za", fold.toggle)
-- --#endregion keymap
