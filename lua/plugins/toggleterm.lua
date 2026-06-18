return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<c-\>]],
        start_in_insert = true,
        insert_mappings = false,
        terminal_mappings = false,
        direction = "float",
        float_opts = {
          border = "rounded",
        },
      })

      local Terminal = require("toggleterm.terminal").Terminal

      local function project_root()
        local file = vim.api.nvim_buf_get_name(0)
        local dir = file ~= "" and vim.fs.dirname(file) or vim.uv.cwd()

        local current = dir
        while current and current ~= "" do
          if vim.fs.basename(current) == "code" and vim.uv.fs_stat(current .. "/pom.xml") then
            return current
          end

          local parent = vim.fs.dirname(current)
          if parent == current then
            break
          end
          current = parent
        end

        local root = vim.fs.find({ "mvnw", "pom.xml", ".git" }, { upward = true, path = dir })[1]
        if root then
          return vim.fs.dirname(root)
        end

        return vim.uv.cwd()
      end

      local float_terminals = {
        [100] = Terminal:new({ id = 100, direction = "float", hidden = true }),
        [101] = Terminal:new({ id = 101, direction = "float", hidden = true }),
        [102] = Terminal:new({ id = 102, direction = "float", hidden = true }),
        [103] = Terminal:new({ id = 103, direction = "float", hidden = true }),
        [104] = Terminal:new({ id = 104, direction = "float", hidden = true }),
      }

      local horizontal_terminals = {
        [200] = Terminal:new({ id = 200, direction = "horizontal", size = 12, hidden = true }),
        [201] = Terminal:new({ id = 201, direction = "horizontal", size = 12, hidden = true }),
        [202] = Terminal:new({ id = 202, direction = "horizontal", size = 12, hidden = true }),
        [203] = Terminal:new({ id = 203, direction = "horizontal", size = 12, hidden = true }),
        [204] = Terminal:new({ id = 204, direction = "horizontal", size = 12, hidden = true }),
      }

      local vertical_terminals = {
        [300] = Terminal:new({ id = 300, direction = "vertical", size = 80, hidden = true }),
        [301] = Terminal:new({ id = 301, direction = "vertical", size = 80, hidden = true }),
        [302] = Terminal:new({ id = 302, direction = "vertical", size = 80, hidden = true }),
        [303] = Terminal:new({ id = 303, direction = "vertical", size = 80, hidden = true }),
        [304] = Terminal:new({ id = 304, direction = "vertical", size = 80, hidden = true }),
      }

      local function toggle_project_terminal(term)
        if term.job_id == nil then
          term.dir = project_root()
        end
        term:toggle()
      end

      local function set_toggle_map(lhs, term, desc)
        vim.keymap.set({ "n", "t" }, lhs, function()
          toggle_project_terminal(term)
        end, { desc = desc })
      end

      set_toggle_map("<leader>tt", float_terminals[100], "Terminal toggle float 1")
      set_toggle_map("<leader>t1t", float_terminals[101], "Terminal toggle float 2")
      set_toggle_map("<leader>t2t", float_terminals[102], "Terminal toggle float 3")
      set_toggle_map("<leader>t3t", float_terminals[103], "Terminal toggle float 4")
      set_toggle_map("<leader>t4t", float_terminals[104], "Terminal toggle float 5")
      set_toggle_map("<leader>th", horizontal_terminals[200], "Terminal toggle horizontal 1")
      set_toggle_map("<leader>t1h", horizontal_terminals[201], "Terminal toggle horizontal 2")
      set_toggle_map("<leader>t2h", horizontal_terminals[202], "Terminal toggle horizontal 3")
      set_toggle_map("<leader>t3h", horizontal_terminals[203], "Terminal toggle horizontal 4")
      set_toggle_map("<leader>t4h", horizontal_terminals[204], "Terminal toggle horizontal 5")
      set_toggle_map("<leader>tv", vertical_terminals[300], "Terminal toggle vertical 1")
      set_toggle_map("<leader>t1v", vertical_terminals[301], "Terminal toggle vertical 2")
      set_toggle_map("<leader>t2v", vertical_terminals[302], "Terminal toggle vertical 3")
      set_toggle_map("<leader>t3v", vertical_terminals[303], "Terminal toggle vertical 4")
      set_toggle_map("<leader>t4v", vertical_terminals[304], "Terminal toggle vertical 5")

      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*toggleterm#*",
        callback = function(ev)
          vim.keymap.set("t", "<leader>t<Esc>", [[<C-\><C-n>]], {
            buffer = ev.buf,
            desc = "Terminal normal mode",
          })

          vim.keymap.set("n", "i", function()
            vim.cmd.startinsert()
          end, {
            buffer = ev.buf,
            desc = "Terminal insert mode",
          })

          vim.keymap.set("n", "a", function()
            vim.cmd.startinsert()
          end, {
            buffer = ev.buf,
            desc = "Terminal append mode",
          })
        end,
      })
    end,
  },
}
