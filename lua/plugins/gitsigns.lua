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

      local function open_diffthis()
        local tabpage = vim.api.nvim_get_current_tabpage()
        local wins_before = vim.api.nvim_tabpage_list_wins(tabpage)
        local origin_win = vim.api.nvim_get_current_win()

        gitsigns.diffthis()

        local wins_after = vim.api.nvim_tabpage_list_wins(tabpage)
        local before = {}
        for _, win in ipairs(wins_before) do
          before[win] = true
        end

        for _, win in ipairs(wins_after) do
          if not before[win] then
            vim.t.gitsigns_diff_win = win
            vim.t.gitsigns_diff_origin_win = origin_win
            return
          end
        end
      end

      local function close_diffthis()
        vim.cmd("diffoff!")

        local diff_win = vim.t.gitsigns_diff_win
        if diff_win and vim.api.nvim_win_is_valid(diff_win) then
          vim.api.nvim_win_close(diff_win, false)
        end

        vim.t.gitsigns_diff_win = nil
        vim.t.gitsigns_diff_origin_win = nil
      end

      vim.keymap.set("n", "]h", gitsigns.next_hunk, { desc = "Git next hunk" })
      vim.keymap.set("n", "[h", gitsigns.prev_hunk, { desc = "Git previous hunk" })
      vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Git preview hunk" })
      vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Git reset hunk" })
      vim.keymap.set("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Git stage hunk" })
      vim.keymap.set("n", "<leader>gS", gitsigns.stage_buffer, { desc = "Git stage buffer" })
      vim.keymap.set("n", "<leader>gu", gitsigns.undo_stage_hunk, { desc = "Git undo stage hunk" })
      vim.keymap.set("n", "<leader>gb", gitsigns.blame_line, { desc = "Git blame line" })
      vim.keymap.set("n", "<leader>gD", open_diffthis, { desc = "Git diff this" })
      vim.keymap.set("n", "<leader>gq", close_diffthis, { desc = "Git quit diff" })
    end,
  },
}
