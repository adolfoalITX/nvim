local M = {}

local state = {
  panel_buf = nil,
  selected_project = nil,
  selected_workspace = nil,
  terminal_buf = nil,
  terminal_win = nil,
  terminal_target = nil,
}

local highlights = {
  header = "AgentsHeader",
  project = "AgentsProject",
  workspace = "AgentsWorkspace",
  active_workspace = "AgentsActiveWorkspace",
  branch = "AgentsBranch",
  opencode = "AgentsOpenCode",
  code = "AgentsVSCode",
  terminal = "AgentsTerminal",
  running = "AgentsRunning",
  stopped = "AgentsStopped",
}

local namespace = vim.api.nvim_create_namespace("agents_panel")

local function is_dir(path)
  local stat = vim.uv.fs_stat(path)
  return stat and stat.type == "directory"
end

local function sorted_directories(path)
  local handle = vim.uv.fs_scandir(path)
  if not handle then
    return {}
  end

  local directories = {}
  while true do
    local name, type = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    end
    if type == "directory" then
      table.insert(directories, { name = name, path = path .. "/" .. name })
    end
  end
  table.sort(directories, function(a, b)
    return a.name < b.name
  end)
  return directories
end

local function projects_root()
  local root = vim.env.NVIM_PROJECTS_ROOT
  if not root or root == "" then
    return root
  end
  return vim.fn.expand(root)
end

local function projects()
  local root = projects_root()
  if not root or root == "" or not is_dir(root) then
    return {}
  end

  local result = {}
  for _, project in ipairs(sorted_directories(root)) do
    if is_dir(project.path .. "/runtimes") then
      table.insert(result, project)
    end
  end
  return result
end

local function workspaces(project)
  if not project then
    return {}
  end
  return sorted_directories(project.path .. "/runtimes")
end

local function tmux_name(workspace)
  return "nvim-agents-" .. vim.fn.sha256(workspace.path):sub(1, 16)
end

local function tmux_ok(arguments)
  vim.fn.system(vim.list_extend({ "tmux" }, arguments))
  return vim.v.shell_error == 0
end

local function ensure_tmux_session(workspace)
  local name = tmux_name(workspace)
  if not tmux_ok({ "has-session", "-t", name }) then
    tmux_ok({ "new-session", "-d", "-s", name, "-c", workspace.path, "-n", "terminal" })
  end
  return name
end

local function tmux_windows(workspace)
  local name = tmux_name(workspace)
  if not tmux_ok({ "has-session", "-t", name }) then
    return {}
  end

  local output = vim.fn.systemlist({ "tmux", "list-windows", "-t", name, "-F", "#{window_index}\t#{window_name}\t#{window_active}\t#{@agents_type}" })
  local windows = {}
  for _, line in ipairs(output) do
    local index, window_name, active, kind = line:match("^(.-)\t(.-)\t(.-)\t(.-)$")
    if index then
      table.insert(windows, { index = index, name = window_name, active = active == "1", kind = kind })
    end
  end
  return windows
end

local function window_icon(window)
  local kind = window.kind
  if kind == "" then
    kind = window.name
  end
  if kind == "code" then
    return "⌘"
  end
  if kind == "opencode" then
    return "◈"
  end
  return ">_"
end

local function window_highlight(window)
  if window.kind == "code" or (window.kind == "" and window.name == "code") then
    return highlights.code
  end
  if window.kind == "opencode" or (window.kind == "" and window.name == "opencode") then
    return highlights.opencode
  end
  return highlights.terminal
end

local function process_file(project)
  local key = vim.fn.sha256(project.path):sub(1, 16)
  return vim.fn.stdpath("state") .. "/agents-aicontext-" .. key
end

local function aicontext_info(project)
  local file = process_file(project)
  if vim.fn.filereadable(file) == 0 then
    return nil
  end
  local lines = vim.fn.readfile(file)
  local pid = tonumber(lines[1])
  if not pid or vim.uv.kill(pid, 0) ~= 0 then
    vim.fn.delete(file)
    return nil
  end
  return { pid = pid, port = tonumber(lines[2]) }
end

local function aicontext_pid(project)
  local info = aicontext_info(project)
  return info and info.pid or nil
end

local function aicontext_port(project)
  local hash = tonumber(vim.fn.sha256(project.path):sub(1, 4), 16)
  return 10000 + (hash % 50000)
end

local function open_aicontext(info)
  if not info.port then
    vim.notify("aicontext is already running, but its URL was not recorded", vim.log.levels.WARN)
    return
  end
  vim.fn.jobstart({ "gio", "open", "http://127.0.0.1:" .. info.port }, { detach = true })
end

local function project_status(project)
  local pid = aicontext_pid(project)
  return pid and "●" or "○", pid and highlights.running or highlights.stopped
end

local function project_label(project)
  return project.name:sub(1, 2):upper()
end

local function refresh()
  if not state.panel_buf or not vim.api.nvim_buf_is_valid(state.panel_buf) then
    return
  end

  local lines = {}
  local items = {}
  local row_highlights = {}
  local function add(line, item, segments)
    table.insert(lines, line)
    items[#lines] = item
    row_highlights[#lines] = segments
  end

  local root = projects_root()
  add(" AGENTS", { kind = "header" }, { { 0, -1, highlights.header } })
  if not root or root == "" then
    add(" NVIM_PROJECTS_ROOT is not set", { kind = "message" })
  elseif not is_dir(root) then
    add(" Invalid root: " .. root, { kind = "message" })
  else
    for _, project in ipairs(projects()) do
      local selected = state.selected_project and state.selected_project.path == project.path
      local label = "[ " .. project_label(project) .. " ]"
      local status, status_highlight = project_status(project)
      local line = "  " .. label .. "  " .. status
      add(line, {
        kind = "project",
        project = project,
      }, {
        { 2, 2 + #label, highlights.project },
        { #line - #status, #line, status_highlight },
      })
      if selected then
        for _, workspace in ipairs(workspaces(project)) do
          local active = state.selected_workspace and state.selected_workspace.path == workspace.path
          local line = "  ├─ " .. workspace.name
          add(line, {
            kind = "workspace",
            project = project,
            workspace = workspace,
          }, {
            { 2, 5, highlights.branch },
            { 5, -1, active and highlights.active_workspace or highlights.workspace },
          })
          if active then
            local windows = tmux_windows(workspace)
            for index, window in ipairs(windows) do
              local connector = index == #windows and "     └─ " or "     ├─ "
              local icon = window_icon(window)
              local line = connector .. icon .. " " .. window.name
              add(line, {
                kind = "window",
                project = project,
                workspace = workspace,
                window = window,
              }, {
                { 5, 8, highlights.branch },
                { 8, -1, window_highlight(window) },
              })
            end
          end
        end
      end
    end
  end

  vim.bo[state.panel_buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.panel_buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(state.panel_buf, namespace, 0, -1)
  for row, segments in pairs(row_highlights) do
    for _, segment in ipairs(segments or {}) do
      vim.api.nvim_buf_add_highlight(state.panel_buf, namespace, segment[3], row - 1, segment[1], segment[2])
    end
  end
  vim.b[state.panel_buf].agents_items = items
  vim.bo[state.panel_buf].modifiable = false
end

local function setup_highlights()
  vim.api.nvim_set_hl(0, highlights.header, { fg = "#89b4fa", bold = true })
  vim.api.nvim_set_hl(0, highlights.project, { fg = "#cba6f7", bold = true })
  vim.api.nvim_set_hl(0, highlights.workspace, { fg = "#bac2de" })
  vim.api.nvim_set_hl(0, highlights.active_workspace, { fg = "#f9e2af", bold = true })
  vim.api.nvim_set_hl(0, highlights.branch, { fg = "#585b70" })
  vim.api.nvim_set_hl(0, highlights.opencode, { fg = "#a6e3a1" })
  vim.api.nvim_set_hl(0, highlights.code, { fg = "#89b4fa" })
  vim.api.nvim_set_hl(0, highlights.terminal, { fg = "#fab387" })
  vim.api.nvim_set_hl(0, highlights.running, { fg = "#a6e3a1", bold = true })
  vim.api.nvim_set_hl(0, highlights.stopped, { fg = "#6c7086" })
end

local function clear_terminal()
  if state.terminal_win and vim.api.nvim_win_is_valid(state.terminal_win) then
    local empty_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(state.terminal_win, empty_buf)
  end
  state.terminal_buf = nil
  state.terminal_target = nil
end

local function focus_vscode(workspace)
  vim.fn.jobstart({ "code", workspace.path }, { detach = true })
end

local function attach(workspace, window)
  if window and window.kind == "code" then
    focus_vscode(workspace)
    return
  end
  local session = ensure_tmux_session(workspace)
  if window then
    tmux_ok({ "select-window", "-t", session .. ":" .. window.index })
  end
  vim.cmd("cd " .. vim.fn.fnameescape(workspace.path))
  if not state.terminal_win or not vim.api.nvim_win_is_valid(state.terminal_win) then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) ~= state.panel_buf then
        state.terminal_win = win
        break
      end
    end
  end

  if not state.terminal_win then
    vim.notify("No central window available for tmux", vim.log.levels.ERROR)
    return
  end

  local previous_buf = state.terminal_buf
  local terminal_buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_win_set_buf(state.terminal_win, terminal_buf)
  state.terminal_buf = terminal_buf
  local active_window
  for _, candidate in ipairs(tmux_windows(workspace)) do
    if candidate.active then
      active_window = candidate
      break
    end
  end
  state.terminal_target = active_window and { session = session, window = active_window.index } or nil
  vim.api.nvim_set_current_win(state.terminal_win)
  vim.fn.termopen({ "tmux", "attach-session", "-t", session }, {
    on_exit = function()
      if state.terminal_buf == terminal_buf then
        vim.schedule(clear_terminal)
      end
    end,
  })
  if previous_buf and vim.api.nvim_buf_is_valid(previous_buf) then
    vim.api.nvim_buf_delete(previous_buf, { force = true })
  end
  vim.schedule(refresh)
  vim.cmd.startinsert()
end

local function create_window(workspace, kind)
  local session = tmux_name(workspace)
  local exists = tmux_ok({ "has-session", "-t", session })
  local arguments
  if exists then
    arguments = { "new-window", "-t", session, "-c", workspace.path }
  else
    arguments = { "new-session", "-d", "-s", session, "-c", workspace.path }
  end
  if kind == "opencode" then
    vim.list_extend(arguments, { "-n", "opencode", "opencode" })
  elseif kind == "code" then
    vim.list_extend(arguments, { "-n", "code", "code .; exec \"$SHELL\"" })
  else
    table.insert(arguments, "-n")
    table.insert(arguments, "terminal")
  end
  if tmux_ok(arguments) then
    local target = exists and (session .. ":") or (session .. ":0")
    tmux_ok({ "set-option", "-w", "-t", target, "@agents_type", kind })
    if kind == "code" then
      focus_vscode(workspace)
      refresh()
    else
      attach(workspace)
    end
  else
    vim.notify("Could not create tmux window", vim.log.levels.ERROR)
  end
end

local function kill_window(workspace, window)
  local session = tmux_name(workspace)
  if tmux_ok({ "kill-window", "-t", session .. ":" .. window.index }) then
    if state.terminal_target and state.terminal_target.session == session and state.terminal_target.window == window.index then
      clear_terminal()
    end
    vim.notify("Closed tmux window " .. window.name)
    refresh()
  else
    vim.notify("Could not close tmux window " .. window.name, vim.log.levels.ERROR)
  end
end

local function rename_window(workspace, window)
  vim.ui.input({ prompt = "Session name: ", default = window.name }, function(name)
    if not name or name == "" or name == window.name then
      return
    end
    local session = tmux_name(workspace)
    if tmux_ok({ "rename-window", "-t", session .. ":" .. window.index, name }) then
      refresh()
    else
      vim.notify("Could not rename tmux window", vim.log.levels.ERROR)
    end
  end)
end

local function show_project_info(project)
  local workspace_count = #workspaces(project)
  local session_count = 0
  for _, workspace in ipairs(workspaces(project)) do
    session_count = session_count + #tmux_windows(workspace)
  end
  local info = aicontext_info(project)
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = {
    " " .. project.name,
    " " .. project.path,
    " " .. workspace_count .. " workspaces | " .. session_count .. " sessions",
    " aicontext: " .. (info and ("http://127.0.0.1:" .. info.port) or "stopped"),
  }
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.api.nvim_strwidth(line))
  end
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = width,
    height = #lines,
    style = "minimal",
    border = "rounded",
    focusable = false,
  })
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_create_autocmd({ "CursorMoved", "WinLeave", "BufLeave" }, {
    buffer = state.panel_buf,
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
  })
end

local function show_help()
  local lines = {
    " Agents shortcuts",
    " Enter / Click  Expand or open",
    " o              New OpenCode session",
    " c              Open workspace in VS Code",
    " t              New terminal session",
    " r              Rename selected session",
    " d              Close selected session",
    " a / x          Start / stop aicontext",
    " i              Project information",
    " R              Refresh panel",
  }
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.api.nvim_strwidth(line))
  end
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "win",
    win = vim.api.nvim_get_current_win(),
    row = 1,
    col = 1,
    width = width,
    height = #lines,
    style = "minimal",
    border = "rounded",
    title = " Help ",
    title_pos = "center",
    focusable = false,
  })
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_create_autocmd({ "CursorMoved", "WinLeave", "BufLeave" }, {
    buffer = state.panel_buf,
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
  })
end

local function start_aicontext(project)
  local existing = aicontext_pid(project)
  if existing then
    vim.notify("Reusing aicontext process " .. existing .. " for " .. project.name)
    open_aicontext(aicontext_info(project))
    return
  end
  local port = aicontext_port(project)
  local job = vim.fn.jobstart({ "sh", "-lc", "exec aicontext console --port " .. port .. " --no-open >/dev/null 2>&1" }, {
    cwd = project.path,
    detach = true,
  })
  if job <= 0 then
    vim.notify("Could not start aicontext console", vim.log.levels.ERROR)
    return
  end
  local pid = vim.fn.jobpid(job)
  local info = { pid = pid, port = port }
  vim.fn.writefile({ tostring(info.pid), tostring(info.port) }, process_file(project))
  open_aicontext(info)
  vim.notify("Started aicontext console for " .. project.name)
  refresh()
end

local function stop_aicontext(project)
  local pid = aicontext_pid(project)
  if not pid then
    vim.notify("No active aicontext process for " .. project.name)
    refresh()
    return
  end
  if vim.uv.kill(pid, "sigterm") == 0 then
    vim.notify("Stopped aicontext process " .. pid)
  else
    vim.notify("Could not stop aicontext process " .. pid, vim.log.levels.ERROR)
  end
  vim.fn.delete(process_file(project))
  refresh()
end

local function kill_all_sessions()
  local sessions = vim.fn.systemlist({ "tmux", "list-sessions", "-F", "#{session_name}" })
  local killed = 0
  for _, session in ipairs(sessions) do
    if vim.startswith(session, "nvim-agents-") and tmux_ok({ "kill-session", "-t", session }) then
      killed = killed + 1
    end
  end
  if state.terminal_win and vim.api.nvim_win_is_valid(state.terminal_win) then
    clear_terminal()
  end
  vim.notify(killed == 0 and "No agents tmux sessions to close" or ("Closed " .. killed .. " agents tmux session(s)"))
  refresh()
end

local function select_current()
  local item = vim.b.agents_items and vim.b.agents_items[vim.fn.line(".")]
  if not item then
    return
  end
  if item.kind == "project" then
    if state.selected_project and state.selected_project.path == item.project.path then
      state.selected_project = nil
    else
      state.selected_project = item.project
    end
    state.selected_workspace = nil
    refresh()
  elseif item.kind == "workspace" then
    state.selected_project = item.project
    state.selected_workspace = item.workspace
    refresh()
  elseif item.kind == "window" then
    attach(item.workspace, item.window)
  end
end

local function with_workspace(callback)
  if not state.selected_workspace then
    vim.notify("Select a workspace first", vim.log.levels.WARN)
    return
  end
  callback(state.selected_workspace)
end

local function with_project(callback)
  if not state.selected_project then
    vim.notify("Select a project first", vim.log.levels.WARN)
    return
  end
  callback(state.selected_project)
end

function M.open()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == state.panel_buf then
      vim.api.nvim_set_current_win(win)
      refresh()
      return
    end
  end
  state.terminal_win = vim.api.nvim_get_current_win()
  vim.cmd("topleft 36vnew")
  state.panel_buf = vim.api.nvim_get_current_buf()
  vim.bo[state.panel_buf].buftype = "nofile"
  vim.bo[state.panel_buf].bufhidden = "hide"
  vim.bo[state.panel_buf].swapfile = false
  vim.bo[state.panel_buf].modifiable = false
  vim.bo[state.panel_buf].filetype = "agents"
  vim.wo.cursorline = true
  vim.wo.winbar = " Agents  |  h Help"
  vim.api.nvim_buf_set_name(state.panel_buf, "Agents")
  vim.keymap.set("n", "<CR>", select_current, { buffer = state.panel_buf, desc = "Agents select" })
  vim.keymap.set("n", "<LeftMouse>", select_current, { buffer = state.panel_buf, desc = "Agents select" })
  vim.keymap.set("n", "R", refresh, { buffer = state.panel_buf, desc = "Agents refresh" })
  vim.keymap.set("n", "o", function() with_workspace(function(workspace) create_window(workspace, "opencode") end) end, { buffer = state.panel_buf, desc = "Agents new opencode" })
  vim.keymap.set("n", "c", function() with_workspace(function(workspace) create_window(workspace, "code") end) end, { buffer = state.panel_buf, desc = "Agents open VS Code" })
  vim.keymap.set("n", "t", function() with_workspace(function(workspace) create_window(workspace, "terminal") end) end, { buffer = state.panel_buf, desc = "Agents new terminal" })
  vim.keymap.set("n", "d", function()
    local item = vim.b.agents_items and vim.b.agents_items[vim.fn.line(".")]
    if item and item.kind == "window" then
      kill_window(item.workspace, item.window)
    else
      vim.notify("Select a tmux window first", vim.log.levels.WARN)
    end
  end, { buffer = state.panel_buf, desc = "Agents close tmux window" })
  vim.keymap.set("n", "r", function()
    local item = vim.b.agents_items and vim.b.agents_items[vim.fn.line(".")]
    if item and item.kind == "window" then
      rename_window(item.workspace, item.window)
    else
      vim.notify("Select a tmux window first", vim.log.levels.WARN)
    end
  end, { buffer = state.panel_buf, desc = "Agents rename tmux window" })
  vim.keymap.set("n", "i", function()
    local item = vim.b.agents_items and vim.b.agents_items[vim.fn.line(".")]
    if item and item.kind == "project" then
      show_project_info(item.project)
    else
      vim.notify("Select a project first", vim.log.levels.WARN)
    end
  end, { buffer = state.panel_buf, desc = "Agents project information" })
  vim.keymap.set("n", "h", show_help, { buffer = state.panel_buf, desc = "Agents shortcuts" })
  vim.keymap.set("n", "a", function() with_project(start_aicontext) end, { buffer = state.panel_buf, desc = "Agents start aicontext" })
  vim.keymap.set("n", "x", function() with_project(stop_aicontext) end, { buffer = state.panel_buf, desc = "Agents stop aicontext" })
  refresh()
end

function M.setup()
  setup_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = setup_highlights })
  vim.keymap.set("n", "<leader>aa", M.open, { desc = "Agents panel" })
  vim.keymap.set("n", "<leader>as", function() with_project(start_aicontext) end, { desc = "Agents start aicontext" })
  vim.keymap.set("n", "<leader>ax", function() with_project(stop_aicontext) end, { desc = "Agents stop aicontext" })
  vim.keymap.set("n", "<leader>aD", kill_all_sessions, { desc = "Agents close all tmux sessions" })
  vim.api.nvim_create_user_command("Agents", M.open, {})
  vim.api.nvim_create_user_command("AgentsAicontextStart", function() with_project(start_aicontext) end, {})
  vim.api.nvim_create_user_command("AgentsAicontextStop", function() with_project(stop_aicontext) end, {})
  vim.api.nvim_create_user_command("AgentsCloseAll", kill_all_sessions, {})
  vim.schedule(M.open)
end

return M
