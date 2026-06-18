return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    keys = {
      { '<leader>ee', '<cmd>Neotree toggle left<cr>', desc = 'Explorer toggle' },
      { '<leader>ef', '<cmd>Neotree filesystem reveal left<cr>', desc = 'Explorer reveal file' },
      { '<leader>eg', '<cmd>Neotree git_status toggle left<cr>', desc = 'Explorer git status' },
    },
    opts = {
      window = {
        mappings = {
          ["<leader>ep"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg("+", path)
              vim.notify("Copied path: " .. path)
            end,
            desc = "Copy absolute path",
          },
          ["<leader>eP"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              local relative = vim.fn.fnamemodify(path, ":.")
              vim.fn.setreg("+", relative)
              vim.notify("Copied relative path: " .. relative)
            end,
            desc = "Copy relative path",
          },
        },
      },
    },
    lazy = false, -- neo-tree will lazily load itself
  }
}
