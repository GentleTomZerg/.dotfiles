local opt = vim.opt -- set local variable

-- line number
opt.relativenumber = true -- 显示相对行号
opt.number = true -- 显示行号

-- 缩进
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

-- 防止字符被包裹
opt.wrap = false

-- 高亮光标行
opt.cursorline = true

-- 启用鼠标
opt.mouse:append("a")

-- 启用系统剪贴板
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.signcolumn = "yes" -- 左侧多一列，有利于debug和插件提示
