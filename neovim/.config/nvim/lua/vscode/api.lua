local vscode = require("vscode-neovim")

local whichkey = {
  show = function()
    vscode.call("whichkey.show")
  end,
}
local comment = {
  selected = function()
    -- vim.fn.VSCodeNotifyRange("editor.action.commentLine", vim.fn.line("v"), vim.fn.line("."), 1)
    vscode.call("editor.action.commentLine")
  end,
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
  end,
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
  end,
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
  end,
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
  end,
  quickFix = function()
    vscode.call("editor.action.quickFix")
  end,
}

return {
  file = file,
  workbench = workbench,
  lsp = lsp,
  comment = comment,
  editor = editor,
  git = git,
}
