---@module 'snacks.terminal'

---@param filepath? string
---@return string|nil
local function find_git_root(filepath)
  if filepath == nil then
    if vim.bo.filetype == "oil" then
      filepath = require("oil").get_current_dir()
    else
      filepath = vim.fn.expand("%")
    end
  end

  if filepath == nil then
    return nil
  end

  local path = vim.uv.fs_realpath(filepath)
  print("PATH", path)

  while path ~= "/" do
    if vim.uv.fs_stat(path .. "/.git") then
      return path
    end
    path = vim.uv.fs_realpath(path .. "/..")
  end
  return nil
end

-- When the current buffer is outside the current workdir it returns the git root for that buffer,
-- Otherwise, returns nil.
---@return string|nil
local function identify_workdir()
  local buffer = require("stuff.util.buffer")
  if buffer.is_unsaved() or buffer.is_in_cwd() then
    return nil
  end

  return find_git_root()
end

---@param args string|string[]
---@param opts? snacks.terminal.Opts
local function run(args, opts)
  assert(#args > 0, "Expected at least 1 argument to git.run()")
  local cwd = identify_workdir()

  opts = vim.tbl_extend("force", {
    auto_close = false,
    cwd = cwd,
  }, opts or {})

  if type(args) == "string" then
    args = { args }
  end

  local cmd = vim.list_extend({ "git" }, args)

  Snacks.terminal(cmd, opts)
end

---@params args string|string[]
---@params opts? snacks.terminal.Opts
local function tig(args, opts)
  local cwd = identify_workdir()
  opts = vim.tbl_extend("force", {
    cwd = cwd,
  }, opts or {})

  if type(args) == "string" then
    args = { args }
  end

  local cmd = vim.list_extend({ "tig" }, args)
  vim.defer_fn(function()
    Snacks.terminal(cmd, opts)
  end, 0)
end

---@param args string[]
---@return string|nil
local function silent_run(args)
  local shell = require("stuff.util.shell")
  local result = shell("git", { args = args })

  if result.code ~= 0 then
    return nil
  end

  return vim.trim(result.stdout)
end

---@params key string
local function get_config(key)
  return silent_run({ "config", "--get", key })
end

---@return string|nil
local function toplevel()
  return silent_run({ "rev-parse", "--show-toplevel" })
end

---@return string[]
local function remotes()
  local raw = silent_run({ "remote" })
  if raw == nil then
    return {}
  end
  return vim.split(raw, "\n")
end

return {
  run = run,
  tig = tig,
  get_config = get_config,
  identify_workdir = identify_workdir,
  find_git_root = find_git_root,
  remotes = remotes,
  toplevel = toplevel,
}
