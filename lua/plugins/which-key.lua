return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 300,
      spec = {
        { "<leader>b", group = "buffers" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "diagnostics" },
        { "<leader>e", group = "explorer" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>r", group = "rest" },
        { "<leader>t", group = "terminal", mode = { "n", "t" } },
        { "<leader>t<Esc>", desc = "Terminal normal mode", mode = "t" },
        { "<leader>w", group = "windows" },
      },
    },
  },
}
