vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.timeout = true
vim.opt.timeoutlen = 3000

do
  local ts = vim.treesitter
  local start = ts.start

  ts.start = function(bufnr, lang)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype == "kulala_ui" then
      return
    end

    return start(bufnr, lang)
  end
end

vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"

local function close_buffer_preserve_layout()
  local current = vim.api.nvim_get_current_buf()
  local listed = vim.fn.getbufinfo({ buflisted = 1 })

  for _, buf in ipairs(listed) do
    if buf.bufnr ~= current and vim.api.nvim_buf_is_valid(buf.bufnr) then
      vim.api.nvim_set_current_buf(buf.bufnr)
      vim.cmd.bdelete({ current, bang = false })
      return
    end
  end

  vim.cmd.enew()
  vim.cmd.bdelete({ current, bang = false })
end

local function close_all_buffers_preserve_layout()
  local listed = vim.fn.getbufinfo({ buflisted = 1 })

  if #listed == 0 then
    return
  end

  vim.cmd.enew()
  local keep = vim.api.nvim_get_current_buf()

  for _, buf in ipairs(listed) do
    if buf.bufnr ~= keep and vim.api.nvim_buf_is_valid(buf.bufnr) then
      pcall(vim.cmd.bdelete, { buf.bufnr, bang = false })
    end
  end
end

vim.keymap.set("n", "<leader>ba", close_all_buffers_preserve_layout, { desc = "Buffer delete all" })
vim.keymap.set("n", "<leader>bb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>bd", close_buffer_preserve_layout, { desc = "Buffer delete" })
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Buffer next" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Buffer previous" })
vim.keymap.set("n", "<leader>r", "<Nop>", { desc = "REST" })
vim.keymap.set("n", "<leader>io", function()
  vim.fn.jobstart({ "gio", "open", vim.fn.expand("%:p") }, { detach = true })
end, { desc = "Open current file externally" })

vim.keymap.set("n", "<leader>ws", "<cmd>split<cr>", { desc = "Window split horizontal" })
vim.keymap.set("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Window split vertical" })
vim.keymap.set("n", "<leader>wq", "<cmd>close<cr>", { desc = "Window close" })
vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Window right" })

require("config.lazy")
