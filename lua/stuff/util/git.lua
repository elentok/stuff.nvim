---@module 'snacks.terminal'

---@return string|nil
local function find_git_root()
  local filepath
  if vim.bo.filetype == "oil" then
    filepath = require("oil").get_current_dir()
  else
    filepath = vim.fn.expand("%")
  end

  if filepath == nil then
    return nil
  end

  local path = vim.uv.fs_realpath(filepath)

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

---@param commit_hash string
---@param commit_title string?
local function fixup(commit_hash, commit_title)
  if commit_hash == nil then
    return
  end

  local ui = require("stuff.util.ui")
  local git = require("stuff.util.git")

  local title = commit_title or commit_hash

  if ui.confirm("Fixup " .. title .. "?") then
    git.run({ "commit", "--fixup", commit_hash })
  end
end

---@param file string
local function stage_patch(file)
  local git = require("stuff.util.git")
  git.run({ "add", "-p", file })
end

return {
  run = run,
  tig = tig,
  fixup = fixup,
  stage_patch = stage_patch,
}
