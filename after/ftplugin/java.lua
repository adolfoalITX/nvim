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

  local mason_lombok = vim.fn.stdpath("data") .. "/mason/packages/jdtls/lombok.jar"
  if vim.uv.fs_stat(mason_lombok) then
    return mason_lombok
  end

  local jars = vim.fn.glob(vim.fn.expand("~/.m2/repository/org/projectlombok/lombok/*/lombok-*.jar"), false, true)
  for i = #jars, 1, -1 do
    local jar = jars[i]
    if jar:match("%-sources%.jar$") == nil and jar:match("%-javadoc%.jar$") == nil then
      return jar
    end
  end

  return nil
end

local function workspace_dir_for(root_dir)
  local project_key = root_dir:gsub("[/\\:]", "%%")
  return vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. project_key
end

local root_dir = find_root_dir()
if not root_dir then
  return
end

local cmd = { "jdtls", "--jvm-arg=-Xms512m", "--jvm-arg=-Xmx2g" }

local lombok_jar = find_lombok_jar()

if lombok_jar then
  table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok_jar)
  table.insert(cmd, "--jvm-arg=-Xbootclasspath/a:" .. lombok_jar)
end

table.insert(cmd, "-data")
table.insert(cmd, workspace_dir_for(root_dir))

jdtls.start_or_attach({
  cmd = cmd,
  root_dir = root_dir,
  capabilities = capabilities,
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
