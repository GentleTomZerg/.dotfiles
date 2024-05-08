local vscode = require('vscode-neovim')

local whichkey = {
    show = function()
        vscode.call("whichkey.show")
    end
}
local comment = {
    selected = function()
        -- vim.fn.VSCodeNotifyRange("editor.action.commentLine", vim.fn.line("v"), vim.fn.line("."), 1)
        vscode.call("editor.action.commentLine")
    end
}
local file = {
    new = function()
        vscode.call("workbench.explorer.fileView.focus")
        vscode.call("explorer.newFile")
    end,

    save = function()
        vscode.call("workbench.action.files.save")
    end,

    saveAll = function()
        vscode.call("workbench.action.files.saveAll")
    end,


    showInExplorer = function()
        vscode.call("workbench.files.action.showActiveFileInExplorer")
    end,

    rename = function()
        vscode.call("workbench.files.action.showActiveFileInExplorer")
        vscode.call("renameFile")
    end
}

-- local error = {
--   list = function()
--     vscode.call("workbench.actions.view.problems")
--   end,
--   next = function()
--     vscode.call("editor.action.marker.next")
--   end,
--   previous = function()
--     vscode.call("editor.action.marker.prev")
--   end,
-- }

local editor = {
    closeActive = function()
        vscode.call("workbench.action.closeActiveEditor")
    end,

    closeOther = function()
        vscode.call("workbench.action.closeOtherEditors")
    end,

    organizeImport = function()
        vscode.call("editor.action.organizeImports")
    end
}

local workbench = {
    showCommands = function()
        vscode.call("workbench.action.showCommands")
    end,
    previousEditor = function()
        vscode.call("workbench.action.previousEditor")
    end,
    nextEditor = function()
        vscode.call("workbench.action.nextEditor")
    end,
    focusExplorer = function()
        vscode.call("workbench.explorer.fileView.focus")
    end,
    revealInExplorer = function()
        vscode.call("revealInExplorer")
    end

}

local toggle = {
    toggleActivityBar = function()
        vscode.call("workbench.action.toggleActivityBarVisibility")
    end,
    toggleSideBarVisibility = function()
        vscode.call("workbench.action.toggleSidebarVisibility")
    end,
    toggleZenMode = function()
        vscode.call("workbench.action.toggleZenMode")
    end,
    theme = function()
        vscode.call("workbench.action.selectTheme")
    end,
}

local symbol = {
    rename = function()
        vscode.call("editor.action.rename")
    end,
}

-- if bookmark extension is used
local bookmark = {
    toggle = function()
        vscode.call("bookmarks.toggle")
    end,
    list = function()
        vscode.call("bookmarks.list")
    end,
    previous = function()
        vscode.call("bookmarks.jumpToPrevious")
    end,
    next = function()
        vscode.call("bookmarks.jumpToNext")
    end,
}

local search = {
    reference = function()
        vscode.call("editor.action.referenceSearch.trigger")
    end,
    referenceInSideBar = function()
        vscode.call("references-view.find")
    end,
    project = function()
        vscode.call("editor.action.addSelectionToNextFindMatch")
        vscode.call("workbench.action.findInFiles")
    end,
    text = function()
        vscode.call("workbench.action.findInFiles")
    end,
}

local project = {
    findFile = function()
        vscode.call("workbench.action.quickOpen")
    end,
    switch = function()
        vscode.call("workbench.action.openRecent")
    end,
    tree = function()
        vscode.call("workbench.view.explorer")
    end,
}

local git = {
    init = function()
        vscode.call("git.init")
    end,
    status = function()
        vscode.call("workbench.view.scm")
    end,
    switch = function()
        vscode.call("git.checkout")
    end,
    deleteBranch = function()
        vscode.call("git.deleteBranch")
    end,
    push = function()
        vscode.call("git.push")
    end,
    pull = function()
        vscode.call("git.pull")
    end,
    fetch = function()
        vscode.call("git.fetch")
    end,
    commit = function()
        vscode.call("git.commit")
    end,
    publish = function()
        vscode.call("git.publish")
    end,

    -- if gitlens installed
    graph = function()
        vscode.call("gitlens.showGraphPage")
    end,
}

local fold = {
    toggle = function()
        vscode.call("editor.toggleFold")
    end,

    all = function()
        vscode.call("editor.foldAll")
    end,
    openAll = function()
        vscode.call("editor.unfoldAll")
    end,

    close = function()
        vscode.call("editor.fold")
    end,
    open = function()
        vscode.call("editor.unfold")
    end,
    openRecursive = function()
        vscode.call("editor.unfoldRecursively")
    end,

    blockComment = function()
        vscode.call("editor.foldAllBlockComments")
    end,

    allMarkerRegion = function()
        vscode.call("editor.foldAllMarkerRegions")
    end,
    openAllMarkerRegion = function()
        vscode.call("editor.unfoldAllMarkerRegions")
    end,
}

-- local vscode = {
--   focusEditor = function()
--     vscode.call("workbench.action.focusActiveEditorGroup")
--   end,
--   moveSideBarRight = function()
--     vscode.call("workbench.action.moveSideBarRight")
--   end,
--   moveSideBarLeft = function()
--     vscode.call("workbench.action.moveSideBarLeft")
--   end,
-- }

local refactor = {
    showMenu = function()
        vscode.call("editor.action.refactor")
    end,
}

local lsp = {
    format = function()
        vscode.call("editor.action.formatDocument")
    end,
    rename = function()
        vscode.call("editor.action.rename")
    end,
    showSymbols = function()
        vscode.call("outline.focus")
    end,
    goImpl = function()
        vscode.call("editor.action.goToImplementation")
    end,
    goRef = function()
        vscode.call("editor.action.goToReferences")
    end
}

-- https://vi.stackexchange.com/a/31887
local nv_keymap = function(lhs, rhs)
    vim.api.nvim_set_keymap('n', lhs, rhs, { noremap = true, silent = true })
    vim.api.nvim_set_keymap('v', lhs, rhs, { noremap = true, silent = true })
end

local nx_keymap = function(lhs, rhs)
    vim.api.nvim_set_keymap('n', lhs, rhs, { silent = true })
    vim.api.nvim_set_keymap('v', lhs, rhs, { silent = true })
end

--#region keymap
vim.keymap.set({ 'n' }, "<leader><cr>", "<cmd>source $MYVIMRC<cr>")
-- #General Mappings
vim.g.mapleader = " "
vim.keymap.set({ 'n' }, "<leader>n", file.new)
vim.keymap.set({ 'n' }, "<leader>w", file.save)
vim.keymap.set({ 'n' }, "<leader>c", editor.closeActive)
vim.keymap.set({ 'n' }, "[t", workbench.previousEditor)
vim.keymap.set({ 'n' }, "]t", workbench.nextEditor)
vim.keymap.set({ 'n', 'v' }, "<leader>/", comment.selected)
vim.keymap.set({ 'n', 'v' }, "H", workbench.previousEditor)
vim.keymap.set({ 'n', 'v' }, "L", workbench.nextEditor)

-- #Explorer
vim.keymap.set({ 'n', 'v' }, "<leader>e", workbench.focusExplorer)
vim.keymap.set({ 'n', 'v' }, "<leader>o", workbench.revealInExplorer)

-- #LSP
vim.keymap.set({ 'n' }, "<leader>lr", lsp.rename)
vim.keymap.set({ 'n' }, "<leader>ls", lsp.showSymbols)
vim.keymap.set({ 'n' }, "gI", lsp.goImpl)
vim.keymap.set({ 'n' }, "gr", lsp.goRef)

nv_keymap('<leader>h', '^')
nv_keymap('<leader>l', '$')
nv_keymap('<leader>a', '%')
nx_keymap('j', 'gj')
nx_keymap('k', 'gk')

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
