vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.timeout = true
vim.opt.timeoutlen = 3000
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"

local directions = {
  h = "h",
  j = "j",
  k = "k",
  l = "l",
  ["<Left>"] = "h",
  ["<Down>"] = "j",
  ["<Up>"] = "k",
  ["<Right>"] = "l",
}

for key, direction in pairs(directions) do
  vim.keymap.set("n", "<C-w>" .. key, "<C-w>" .. direction, { desc = "Window move" })
end

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(event)
    vim.keymap.set("t", "<C-\\><C-n>", [[<C-\><C-n>]], {
      buffer = event.buf,
      desc = "Terminal normal mode",
    })
    vim.keymap.set("t", "<leader>t<Esc>", [[<C-\><C-n>]], {
      buffer = event.buf,
      desc = "Terminal normal mode",
    })
    for key, direction in pairs(directions) do
      vim.keymap.set("t", "<C-w>" .. key, "<C-\\><C-n><C-w>" .. direction, {
        buffer = event.buf,
        desc = "Window move",
      })
    end
  end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { output, "WarningMsg" } }, true, {})
    return
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "agents.plugins" } },
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = true },
  rocks = { enabled = false },
})

require("agents").setup()
