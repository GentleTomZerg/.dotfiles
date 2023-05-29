-- Additional Plugins
lvim.plugins = {
  -- Markdown
  {
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    ft = "markdown",
    config = function()
      vim.g.mkdp_auto_start = 1
    end,
  },

  -- Hop (Like Easymotion)
  -- {
  --   "phaazon/hop.nvim",
  --   event = "BufRead",
  --   config = function()
  --     require("hop").setup()
  --   end,
  -- },

  {
    "phaazon/hop.nvim",
    event = "BufRead",
    config = function()
      require("hop").setup()
      vim.api.nvim_set_keymap("n", "s", ":HopChar2<cr>", { silent = true })
      vim.api.nvim_set_keymap("n", "S", ":HopWord<cr>", { silent = true })
    end,
  },


  {
    "simrat39/symbols-outline.nvim",
    config = function()
      require("symbols-outline").setup()
    end
  },

  "mfussenegger/nvim-jdtls",


  -- {
  --   'Exafunction/codeium.vim',
  --   config = function ()
  --     -- Change '<C-g>' here to any keycode you like.
  --     vim.keymap.set('i', '<c-;>', function () return vim.fn['codeium#Accept']() end, { expr = true })
  --     vim.keymap.set('i', '<c-k>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true })
  --     vim.keymap.set('i', '<c-j>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true })
  --     vim.keymap.set('i', '<c-h>', function() return vim.fn['codeium#Clear']() end, { expr = true })
  --   end
  -- },

}
