local M = {}

function M.is_agents()
  return vim.g.nvim_profile == "agents"
end

return M
