-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- add your own keymapping
  -- basic mappings 
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.keys.normal_mode["H"] = "^"
lvim.keys.normal_mode["L"] = "$"
lvim.keys.normal_mode[";"] = ":"
  -- control split screen
lvim.keys.normal_mode["<A-h>"] = "<C-w><Left>"
lvim.keys.normal_mode["<A-l>"] = '<C-w><Right>'
lvim.keys.normal_mode["<A-j>"] = '<C-w><Down>'
lvim.keys.normal_mode["<A-k>"] = '<C-w><Up>'
  -- insert mode
lvim.keys.insert_mode["<A-l>"] = "<Right>"
lvim.keys.insert_mode["<A-h>"] = "<Left>"
lvim.keys.insert_mode["<A-j>"] = "<Down>"
lvim.keys.insert_mode["<A-k>"] = "<Up>"
lvim.keys.insert_mode["<A-Esc>"] = "``<Left>"



-- Key mappings for hop
  -- place this in one of your configuration file(s)
  -- local hop = require('hop')
  -- local directions = require('hop.hint').HintDirection
  -- vim.keymap.set('', 'f', function()
  --   hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = false })
  -- end, {remap=true})
  -- vim.keymap.set('', 'F', function()
  --   hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = false })
  -- end, {remap=true})
  -- vim.keymap.set('', 't', function()
  --   hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
  -- end, {remap=true})
  -- vim.keymap.set('', 'T', function()
  --   hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
  -- end, {remap=true})
