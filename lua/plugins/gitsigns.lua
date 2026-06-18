return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = false,
      signs_staged_enable = true,
    },
    config = function(_, opts)
      local gitsigns = require("gitsigns")
      gitsigns.setup(opts)

      vim.keymap.set("n", "]h", gitsigns.next_hunk, { desc = "Git next hunk" })
      vim.keymap.set("n", "[h", gitsigns.prev_hunk, { desc = "Git previous hunk" })
      vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Git preview hunk" })
      vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Git reset hunk" })
      vim.keymap.set("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Git stage hunk" })
      vim.keymap.set("n", "<leader>gS", gitsigns.stage_buffer, { desc = "Git stage buffer" })
      vim.keymap.set("n", "<leader>gu", gitsigns.undo_stage_hunk, { desc = "Git undo stage hunk" })
      vim.keymap.set("n", "<leader>gb", gitsigns.blame_line, { desc = "Git blame line" })
      vim.keymap.set("n", "<leader>gD", gitsigns.diffthis, { desc = "Git diff this" })
    end,
  },
}
