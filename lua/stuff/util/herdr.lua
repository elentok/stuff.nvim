---@param args string[]
---@param opts? { stdin?: string, fail_silently?: boolean }
---@return vim.SystemCompleted
local function run(args, opts)
  local shell = require("stuff.util.shell")
  opts = opts or {}

  return shell("herdr", {
    args = args,
    stdin = opts.stdin,
    fail_silently = opts.fail_silently,
  })
end

---@class HerdrAgent
---@field pane_id string
---@field tab_id string
---@field workspace_id string
---@field agent string
---@field agent_status string
---@field cwd string
---@field terminal_title string
---@field focused boolean

---@return boolean
local function is_inside_herdr() return vim.env.HERDR_ENV ~= nil and vim.env.HERDR_ENV ~= "" end

---@return string|nil
local function get_current_tab_id()
  if vim.env.HERDR_TAB_ID == nil or vim.env.HERDR_TAB_ID == "" then return nil end
  return vim.env.HERDR_TAB_ID
end

---@return string|nil
local function get_current_workspace_id()
  if vim.env.HERDR_WORKSPACE_ID == nil or vim.env.HERDR_WORKSPACE_ID == "" then return nil end
  return vim.env.HERDR_WORKSPACE_ID
end

---@return HerdrAgent[]
local function list_agents()
  local result = run({ "agent", "list" }, { fail_silently = true })
  if result.code ~= 0 or result.stdout == nil or result.stdout == "" then return {} end

  local ok, decoded = pcall(vim.json.decode, result.stdout)
  if not ok or type(decoded) ~= "table" then return {} end

  local raw_agents = vim.tbl_get(decoded, "result", "agents")
  if type(raw_agents) ~= "table" then return {} end

  local agents = {} ---@type HerdrAgent[]
  for _, raw_agent in ipairs(raw_agents) do
    agents[#agents + 1] = {
      pane_id = tostring(raw_agent.pane_id or ""),
      tab_id = tostring(raw_agent.tab_id or ""),
      workspace_id = tostring(raw_agent.workspace_id or ""),
      agent = raw_agent.agent or "",
      agent_status = raw_agent.agent_status or "",
      cwd = raw_agent.cwd or "",
      terminal_title = raw_agent.terminal_title_stripped or raw_agent.terminal_title or "",
      focused = raw_agent.focused == true,
    }
  end

  return agents
end

---@param pane_id string
---@param lines? integer
---@return string
local function get_agent_preview(pane_id, lines)
  local result = run(
    { "agent", "read", pane_id, "--lines", tostring(lines or 200) },
    { fail_silently = true }
  )
  if result.code ~= 0 or result.stdout == nil or result.stdout == "" then
    return "Preview unavailable"
  end

  local ok, decoded = pcall(vim.json.decode, result.stdout)
  if not ok or type(decoded) ~= "table" then return "Preview unavailable" end

  local text = vim.tbl_get(decoded, "result", "read", "text")
  if type(text) ~= "string" or text == "" then return "Preview unavailable" end

  return text
end

---@param pane_id string
---@return boolean
local function focus_agent(pane_id)
  local result = run({ "agent", "focus", pane_id }, { fail_silently = true })
  return result.code == 0
end

---@param pane_id string
---@param text string
---@return boolean
local function send_to_agent(pane_id, text)
  if vim.trim(text) == "" then
    vim.notify("Cannot send empty text to herdr agent", vim.log.levels.WARN)
    return false
  end

  local result = run({ "agent", "send", pane_id, text }, { fail_silently = true })
  if result.code ~= 0 then
    vim.notify("Failed to send text to herdr agent " .. pane_id, vim.log.levels.ERROR)
    return false
  end

  return true
end

return {
  run = run,
  is_inside_herdr = is_inside_herdr,
  get_current_tab_id = get_current_tab_id,
  get_current_workspace_id = get_current_workspace_id,
  list_agents = list_agents,
  get_agent_preview = get_agent_preview,
  focus_agent = focus_agent,
  send_to_agent = send_to_agent,
}
