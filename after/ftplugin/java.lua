local jdtls = require("jdtls")

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp_lsp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

local function find_root_dir()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    return nil
  end

  local dir = vim.fs.dirname(file)

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

  local markers = { "mvnw", "pom.xml", ".git" }
  local root = vim.fs.find(markers, { upward = true, path = dir })[1]
  if root then
    return vim.fs.dirname(root)
  end

  return dir
end

local function find_lombok_jar()
  local env_lombok = vim.env.LOMBOK_JAR
  if env_lombok and env_lombok ~= "" and vim.uv.fs_stat(env_lombok) then
    return env_lombok
  end
end

local function workspace_dir_for(root_dir, java)
  -- A workspace created with a different JDK can retain an incompatible model.
  local project_key = (root_dir .. "-" .. java .. "-v2"):gsub("[/\\:]", "%%")
  return vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. project_key
end

local function java_for_project(root_dir)
  local asdf = vim.fn.exepath("asdf")
  if asdf ~= "" then
    local result = vim.system({ asdf, "which", "java" }, { cwd = root_dir, text = true }):wait()
    if result.code == 0 then
      local java = vim.trim(result.stdout)
      if java ~= "" and vim.uv.fs_stat(java) then
        return java
      end
    end
  end

  return vim.fn.exepath("java")
end

local root_dir = find_root_dir()
if not root_dir then
  return
end

local cmd = { "jdtls", "--jvm-arg=-Xms512m", "--jvm-arg=-Xmx2g" }
local java = java_for_project(root_dir)

if java == "" then
  return
end

table.insert(cmd, "--java-executable=" .. java)

local lombok_jar = find_lombok_jar()

if lombok_jar then
  table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok_jar)
  table.insert(cmd, "--jvm-arg=-Xbootclasspath/a:" .. lombok_jar)
end

table.insert(cmd, "-data")
table.insert(cmd, workspace_dir_for(root_dir, java))

jdtls.start_or_attach({
  cmd = cmd,
  root_dir = root_dir,
  capabilities = capabilities,
  handlers = {
    ["language/status"] = function(_, result, ctx)
      if result.type ~= "ServiceReady" then
        return
      end

      local client = vim.lsp.get_client_by_id(ctx.client_id)
      if not client then
        return
      end

      -- Prime the index after Maven import so Trouble does not query it too early.
      for bufnr in pairs(client.attached_buffers) do
        if vim.bo[bufnr].filetype == "java" then
          client:request("textDocument/documentSymbol", {
            textDocument = vim.lsp.util.make_text_document_params(bufnr),
          }, nil, bufnr)
        end
      end
    end,
  },
  init_options = {
    bundles = {},
    extendedClientCapabilities = jdtls.extendedClientCapabilities,
  },
  settings = {
    java = {
      configuration = {
        updateBuildConfiguration = "automatic",
      },
      import = {
        maven = {
          enabled = true,
        },
      },
      maven = {
        downloadSources = true,
      },
    },
  },
})
