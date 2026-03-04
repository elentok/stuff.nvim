---@module 'snacks.terminal'

---@params args string|string[]
---@params opts? snacks.terminal.Opts
local function tig(args, opts)
  local find_repo_root = require("stuff.git.find-repo-root")
  opts = vim.tbl_extend("force", {
    cwd = find_repo_root(),
  }, opts or {})

  if type(args) == "string" then args = { args } end

  local cmd = vim.list_extend({ "tig" }, args)
  vim.defer_fn(function() Snacks.terminal(cmd, opts) end, 0)
end

---@params key string
local function get_config(key) return require("stuff.git.run").silently({ "config", "--get", key }) end

---@return string|nil
local function toplevel()
  return require("stuff.git.run").silently({ "rev-parse", "--show-toplevel" })
end

---@return string[]
local function remotes()
  local raw = require("stuff.git.run").silently({ "remote" })
  if raw == nil then return {} end
  return vim.split(raw, "\n")
end

---@return string|nil
local function find_repo_root()
  local buf = vim.api.nvim_buf_get_name(0)
  local start = (buf ~= "" and vim.fs.dirname(buf)) or vim.loop.cwd()

  local git_entry = vim.fs.find(".git", { path = start, upward = true })[1]
  if not git_entry then return end

  return vim.fs.dirname(git_entry)
end

return {
  tig = tig,
  get_config = get_config,
  remotes = remotes,
  toplevel = toplevel,
  find_repo_root = find_repo_root,
}
