return {
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    cmd = {
      "MarkdownPreview",
      "MarkdownPreviewStop",
      "MarkdownPreviewToggle",
    },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      local opener

      if vim.fn.executable("xdg-open") == 1 then
        opener = { "xdg-open" }
      elseif vim.fn.executable("gio") == 1 then
        opener = { "gio", "open" }
      elseif vim.fn.executable("open") == 1 then
        opener = { "open" }
      end

      vim.g.mkdp_filetypes = { "markdown" }
      if opener then
        _G.open_markdown_preview = function(url)
          local cmd = vim.deepcopy(opener)
          table.insert(cmd, url)
          vim.fn.jobstart(cmd, { detach = true })
        end

        vim.g.mkdp_browserfunc = "OpenMarkdownPreview"

        vim.cmd([[
          function! OpenMarkdownPreview(url) abort
            call v:lua.open_markdown_preview(a:url)
          endfunction
        ]])
      end
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown preview" },
    },
  },
}
