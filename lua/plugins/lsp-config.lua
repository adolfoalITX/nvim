return {
  {
    "mason-org/mason.nvim",
    opts={},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = { "lua_ls", "jdtls"},
      automatic_enable = {
        exclude = { "jdtls" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp_lsp then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      vim.keymap.set("n", "<leader>df", function()
        vim.diagnostic.open_float(0, { scope = "line" })
      end, {
        desc = "Diagnostics: line float",
      })

      vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, {
        desc = "Diagnostics: populate loclist",
      })

      local lsp_group = vim.api.nvim_create_augroup("user_lsp_keymaps", { clear = true })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = lsp_group,
        callback = function(ev)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc, silent = true })
          end

          local has_support = function(method)
            local clients = vim.lsp.get_clients({ bufnr = ev.buf })
            for _, client in ipairs(clients) do
              if client:supports_method(method, ev.buf) then
                return true
              end
            end
            return false
          end

          local safe_lsp_call = function(method, fn)
            return function()
              if not has_support(method) then
                vim.notify("LSP method not supported: " .. method, vim.log.levels.WARN)
                return
              end

              local ok, err = pcall(fn)
              if not ok and err then
                vim.notify(tostring(err), vim.log.levels.ERROR)
              end
            end
          end

          vim.keymap.set("n", "K", vim.lsp.buf.hover, {
            buffer = ev.buf,
            desc = "LSP: Hover",
          })

          map("n", "<leader>cd", safe_lsp_call("textDocument/definition", vim.lsp.buf.definition), "Code: Definition")
          map("n", "<leader>cf", safe_lsp_call("textDocument/formatting", function()
            vim.lsp.buf.format({ async = true })
          end), "Code: Format")
          map("n", "<leader>ci", safe_lsp_call("textDocument/implementation", vim.lsp.buf.implementation), "Code: Implementation")
          map("n", "<leader>cn", safe_lsp_call("textDocument/rename", vim.lsp.buf.rename), "Code: Rename")
          map("n", "<leader>cr", safe_lsp_call("textDocument/references", vim.lsp.buf.references), "Code: References")
          map({ "n", "x" }, "<leader>ca", safe_lsp_call("textDocument/codeAction", vim.lsp.buf.code_action), "Code: Action")
          map("n", "<leader>ct", safe_lsp_call("textDocument/typeDefinition", vim.lsp.buf.type_definition), "Code: Type definition")
        end,
      })

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })
      vim.lsp.enable("lua_ls")
    end,
  },
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
  },
}
