---@param args string|string[]
---@param opts? snacks.terminal.Opts
local function in_terminal(args, opts)
  assert(#args > 0, "Expected at least 1 argument to git.run()")
  local find_repo_root = require("stuff.git.find-repo-root")

  opts = vim.tbl_extend("force", {
    auto_close = false,
    cwd = find_repo_root(),
  }, opts or {})

  if type(args) == "string" then
    args = { args }
  end

  local cmd = vim.list_extend({ "git" }, args)

  Snacks.terminal(cmd, opts)
end

---@param args string[]
---@return string|nil
local function silently(args)
  local shell = require("stuff.util.shell")
  local find_repo_root = require("stuff.git.find-repo-root")
  local result = shell("git", { args = args, cwd = find_repo_root() })

  if result.code ~= 0 then
    return nil
  end

  return vim.trim(result.stdout)
end

return {
  in_terminal = in_terminal,
  silently = silently,
}
