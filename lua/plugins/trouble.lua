return {
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>dd", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics list" },
      { "<leader>db", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics buffer list" },
      { "<leader>dq", "<cmd>Trouble qflist toggle<cr>", desc = "Diagnostics quickfix" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Code symbols" },
      { "<leader>co", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "Code overview" },
    },
  },
}
