---@param args string[]
---@param opts? { stdin?: string, fail_silently?: boolean }
---@return vim.SystemCompleted
local function run(args, opts)
  local shell = require("stuff.util.shell")
  opts = opts or {}

  return shell("tmux", {
    args = args,
    stdin = opts.stdin,
    fail_silently = opts.fail_silently,
  })
end

---@return boolean
local function is_inside_tmux()
  return vim.env.TMUX ~= nil and vim.env.TMUX ~= ""
end

---@return string|nil
local function get_current_tmux_session()
  local result = run({ "display-message", "-p", "#{session_name}" }, { fail_silently = true })
  if result.code ~= 0 or result.stdout == nil then return nil end

  local session = vim.trim(result.stdout)
  if session == "" then return nil end

  return session
end

---@param pane_id string
---@return string
local function get_pane_preview(pane_id)
  local result = run(
    { "capture-pane", "-p", "-e", "-J", "-S", "-200", "-t", pane_id },
    { fail_silently = true }
  )

  if result.code ~= 0 or result.stdout == nil or result.stdout == "" then
    return "Preview unavailable"
  end

  return result.stdout
end

---@param pane_id string
---@param text string
---@return boolean
local function send_to_pane(pane_id, text)
  if vim.trim(text) == "" then
    vim.notify("Cannot send empty text to tmux pane", vim.log.levels.WARN)
    return false
  end

  local load_result = run({ "load-buffer", "-" }, {
    stdin = text,
    fail_silently = true,
  })
  if load_result.code ~= 0 then
    vim.notify("Failed to load text into tmux buffer", vim.log.levels.ERROR)
    return false
  end

  local paste_result = run({ "paste-buffer", "-d", "-p", "-t", pane_id }, { fail_silently = true })
  if paste_result.code ~= 0 then
    vim.notify("Failed to paste text into tmux pane " .. pane_id, vim.log.levels.ERROR)
    return false
  end

  return true
end

return {
  run = run,
  is_inside_tmux = is_inside_tmux,
  get_current_tmux_session = get_current_tmux_session,
  get_pane_preview = get_pane_preview,
  send_to_pane = send_to_pane,
}
