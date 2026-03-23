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

---@class TmuxPane
---@field pane_id string
---@field pane_title string
---@field pane_current_command string
---@field pane_start_command string
---@field pane_current_path string
---@field pane_active boolean
---@field pane_agent_marker string

---@return boolean
local function is_inside_tmux() return vim.env.TMUX ~= nil and vim.env.TMUX ~= "" end

---@return string|nil
local function get_current_tmux_session()
  local result = run({ "display-message", "-p", "#{session_name}" }, { fail_silently = true })
  if result.code ~= 0 or result.stdout == nil then return nil end

  local session = vim.trim(result.stdout)
  if session == "" then return nil end

  return session
end

---@param session string|nil
---@return TmuxPane[]
local function get_session_panes(session)
  local target_session = session
  if target_session == nil or target_session == "" then
    target_session = get_current_tmux_session()
  end
  if target_session == nil then return {} end

  local result = run({
    "list-panes",
    "-s",
    "-t",
    target_session,
    "-F",
    "#{session_name}\t#{pane_id}\t#{pane_title}\t#{pane_current_command}\t#{pane_start_command}\t#{pane_current_path}\t#{pane_active}\t#{@stuff_agent}",
  }, { fail_silently = true })

  if result.code ~= 0 or result.stdout == nil or result.stdout == "" then return {} end

  local panes = {} ---@type TmuxPane[]
  for _, line in ipairs(vim.split(result.stdout, "\n", { trimempty = true })) do
    local fields = vim.split(line, "\t", { plain = true })
    local pane_session = fields[1] or ""
    local pane_id = fields[2]
    local pane_title = fields[3] or ""
    local pane_current_command = fields[4] or ""
    local pane_start_command = fields[5] or ""
    local pane_current_path = fields[6] or ""
    local pane_active = (fields[7] or "") == "1"
    local pane_agent_marker = fields[8] or ""
    if pane_session == target_session and pane_id ~= nil and pane_id ~= "" then
      panes[#panes + 1] = {
        pane_id = pane_id,
        pane_title = pane_title,
        pane_current_command = pane_current_command,
        pane_start_command = pane_start_command,
        pane_current_path = pane_current_path,
        pane_active = pane_active,
        pane_agent_marker = pane_agent_marker,
      }
    end
  end

  return panes
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
---@return boolean
local function focus_pane(pane_id)
  local target_result = run(
    { "display-message", "-p", "-t", pane_id, "#{session_name}\t#{window_index}" },
    { fail_silently = true }
  )
  if target_result.code ~= 0 or target_result.stdout == nil or target_result.stdout == "" then
    return false
  end

  local fields = vim.split(vim.trim(target_result.stdout), "\t", { plain = true })
  local session_name = fields[1]
  local window_index = fields[2]
  if session_name == nil or session_name == "" or window_index == nil or window_index == "" then
    return false
  end

  local window_target = string.format("%s:%s", session_name, window_index)
  local window_result = run({ "select-window", "-t", window_target }, { fail_silently = true })
  if window_result.code ~= 0 then return false end

  local pane_result = run({ "select-pane", "-t", pane_id }, { fail_silently = true })
  return pane_result.code == 0
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
  get_session_panes = get_session_panes,
  get_pane_preview = get_pane_preview,
  focus_pane = focus_pane,
  send_to_pane = send_to_pane,
}
