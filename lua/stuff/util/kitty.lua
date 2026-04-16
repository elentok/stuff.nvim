---@param args string[]
---@param opts? { stdin?: string, fail_silently?: boolean }
---@return vim.SystemCompleted
local function run(args, opts)
  local shell = require("stuff.util.shell")
  opts = opts or {}

  return shell("kitty", {
    args = vim.list_extend({ "@", unpack(args) }, {}),
    stdin = opts.stdin,
    fail_silently = opts.fail_silently,
  })
end

---@class KittyWindow
---@field window_id string
---@field tab_id string
---@field window_title string
---@field window_current_command string
---@field window_start_command string
---@field window_current_path string
---@field window_active boolean
---@field tab_active boolean
---@field window_agent_marker string

---@return boolean
local function is_inside_kitty()
  return vim.env.KITTY_LISTEN_ON ~= nil and vim.env.KITTY_LISTEN_ON ~= ""
end

---@param cmdline string[]|string|nil
---@return string
local function stringify_cmdline(cmdline)
  if type(cmdline) == "string" then return cmdline end
  if type(cmdline) ~= "table" then return "" end
  return table.concat(cmdline, " ")
end

---@param window table
---@return string
local function get_current_command(window)
  local processes = window.foreground_processes
  if type(processes) == "table" then
    local process = processes[#processes]
    if type(process) == "table" then
      local cmdline = stringify_cmdline(process.cmdline)
      if cmdline ~= "" then return cmdline end
    end
  end

  return stringify_cmdline(window.foreground_cmdline)
end

---@param window table
---@return string
local function get_current_path(window)
  local cwd = window.cwd
  if type(cwd) == "string" then return cwd end

  local processes = window.foreground_processes
  if type(processes) == "table" then
    local process = processes[#processes]
    if type(process) == "table" and type(process.cwd) == "string" then return process.cwd end
  end

  return ""
end

---@return KittyWindow[]
local function get_windows()
  local result = run({ "ls" }, { fail_silently = true })
  if result.code ~= 0 or result.stdout == nil or result.stdout == "" then return {} end

  local ok, decoded = pcall(vim.json.decode, result.stdout)
  if not ok or type(decoded) ~= "table" then return {} end

  local windows = {} ---@type KittyWindow[]
  for _, os_window in ipairs(decoded) do
    for _, tab in ipairs(os_window.tabs or {}) do
      for _, window in ipairs(tab.windows or {}) do
        windows[#windows + 1] = {
          window_id = tostring(window.id or ""),
          tab_id = tostring(tab.id or ""),
          window_title = window.title or "",
          window_current_command = get_current_command(window),
          window_start_command = stringify_cmdline(window.cmdline),
          window_current_path = get_current_path(window),
          window_active = window.is_active == true,
          tab_active = tab.is_active == true,
          window_agent_marker = "",
        }
      end
    end
  end

  return windows
end

---@param window_id string
---@return string
local function get_window_preview(window_id)
  local result = run(
    { "get-text", "--match", "id:" .. window_id, "--extent", "screen" },
    { fail_silently = true }
  )

  if result.code ~= 0 or result.stdout == nil or result.stdout == "" then
    return "Preview unavailable"
  end

  return result.stdout
end

---@param window_id string
---@return boolean
local function focus_window(window_id)
  local result = run({ "focus-window", "--match", "id:" .. window_id }, { fail_silently = true })
  return result.code == 0
end

---@param window_id string
---@param text string
---@return boolean
local function send_to_window(window_id, text)
  if vim.trim(text) == "" then
    vim.notify("Cannot send empty text to kitty window", vim.log.levels.WARN)
    return false
  end

  local result = run({
    "send-text",
    "--match",
    "id:" .. window_id,
    "--stdin",
    "--bracketed-paste",
    "auto",
  }, {
    stdin = text,
    fail_silently = true,
  })

  if result.code ~= 0 then
    vim.notify("Failed to paste text into kitty window " .. window_id, vim.log.levels.ERROR)
    return false
  end

  return true
end

---@param command string[]
local function new_tab(command)
  if not is_inside_kitty() then vim.notify("Not inside kitty", vim.log.levels.ERROR) end

  vim.system(vim.list_extend({
    "kitty",
    "@",
    "launch",
    "--type=tab",
    "--location=after",
    "--cwd=current",
    "--copy-env",
  }, command))
end

return {
  run = run,
  is_inside_kitty = is_inside_kitty,
  get_windows = get_windows,
  get_window_preview = get_window_preview,
  focus_window = focus_window,
  send_to_window = send_to_window,
  new_tab = new_tab,
}
