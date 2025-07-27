---@class ShellOpts
---@field args? string[]
---@field fail_silently? boolean
---@field cwd? string
---@field stdin? string|string[]

---@param full_cmd string[]
---@param result vim.SystemCompleted
local function notify_error(full_cmd, result)
  local err = result.stderr
  if err == nil then err = result.stdout end

  vim.notify(
    "Command "
      .. table.concat(full_cmd, " ")
      .. " exited with code "
      .. result.code
      .. "\n\n"
      .. err
  )
end

---@param cmd string
---@param opts? ShellOpts
---@return vim.SystemCompleted
local function shell(cmd, opts)
  opts = opts or {}
  local full_cmd = vim.list_extend({ cmd }, opts.args or {})
  local result = vim.system(full_cmd, { cwd = opts.cwd, stdin = opts.stdin }):wait()

  if result.code ~= 0 and not opts.fail_silently then notify_error(full_cmd, result) end

  return result
end

return shell
