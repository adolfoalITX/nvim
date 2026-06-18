return {
  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    keys = {
      {
        "<leader>rr",
        function()
          require("kulala").run()
        end,
        ft = { "http", "rest" },
        desc = "REST run request",
      },
      {
        "<leader>ra",
        function()
          require("kulala").run_all()
        end,
        ft = { "http", "rest" },
        desc = "REST run all",
      },
      {
        "<leader>ro",
        function()
          require("kulala.ui").open()
        end,
        ft = { "http", "rest" },
        desc = "REST open response",
      },
      {
        "<leader>re",
        function()
          require("kulala").set_selected_env()
        end,
        ft = { "http", "rest" },
        desc = "REST select environment",
      },
    },
    init = function()
      vim.filetype.add({
        extension = {
          http = "http",
          rest = "http",
        },
      })
    end,
    opts = {
      global_keymaps = false,
      kulala_keymaps = true,
      lsp = {
        enable = true,
        keymaps = false,
      },
      ui = {
        default_view = "body",
        display_mode = "split",
        split_direction = "right",
      },
      response_format = {
        indent = 2,
        expand_tabs = true,
        sort_keys = false,
      },
    },
  },
}
