local M = {}

local AGENT_NAMES = { "claude", "codex", "opencode", "cursor-agent" }

---@class StuffPromptAgentTarget
---@field agent string
---@field backend "tmux"|"kitty"
---@field id string
---@field scope_id string
---@field scope_active boolean
---@field title string
---@field current_command string
---@field start_command string
---@field current_path string
---@field active boolean
---@field preview_text string
---@field text string

---@param value string|nil
---@return string|nil
local function detect_agent_name(value)
  if value == nil or value == "" then return nil end

  local lower = value:lower()
  for _, agent in ipairs(AGENT_NAMES) do
    if lower:find(agent, 1, true) then return agent end
  end

  return nil
end

---@param value string
---@return string
local function sanitize_preview_text(value)
  local text = value
  text = text:gsub("\27%[[0-9;?]*[ -/]*[@-~]", "")
  text = text:gsub("\27%][^\7]*\7", "")
  text = text:gsub("\27%].-\27\\", "")
  text = text:gsub("\27", "")
  text = text:gsub("\r", "")
  text = text:gsub("[%z\1-\8\11\12\14-\31\127]", "")
  return text
end

---@param targets StuffPromptAgentTarget[]
---@return StuffPromptAgentTarget[]
local function prefer_active_scope_targets(targets)
  local active_scope_ids = {} ---@type table<string, boolean>
  for _, target in ipairs(targets) do
    if target.scope_active and target.scope_id ~= "" then
      active_scope_ids[target.scope_id] = true
    end
  end

  if vim.tbl_isempty(active_scope_ids) then return targets end

  local preferred = {} ---@type StuffPromptAgentTarget[]
  for _, target in ipairs(targets) do
    if target.scope_id ~= "" and active_scope_ids[target.scope_id] then
      preferred[#preferred + 1] = target
    end
  end

  if #preferred > 0 then return preferred end
  return targets
end

---@return StuffPromptAgentTarget[]
local function find_tmux_agent_targets()
  local tmux = require("stuff.util.tmux")
  local session = tmux.get_current_tmux_session()
  if session == nil then return {} end

  local panes = tmux.get_session_panes(session)
  local agent_targets = {} ---@type StuffPromptAgentTarget[]
  for _, pane in ipairs(panes) do
    local agent = detect_agent_name(pane.pane_agent_marker)
      or detect_agent_name(pane.pane_current_command)
      or detect_agent_name(pane.pane_start_command)
      or detect_agent_name(pane.pane_title)

    if agent ~= nil then
      local preview_text = sanitize_preview_text(tmux.get_pane_preview(pane.pane_id))
      agent_targets[#agent_targets + 1] = {
        agent = agent,
        backend = "tmux",
        id = pane.pane_id,
        scope_id = pane.pane_window_id,
        scope_active = pane.pane_window_active,
        title = pane.pane_title,
        current_command = pane.pane_current_command,
        start_command = pane.pane_start_command,
        current_path = pane.pane_current_path,
        active = pane.pane_active,
        preview_text = preview_text,
        text = table.concat({
          agent,
          pane.pane_id,
          pane.pane_title,
          pane.pane_current_command,
          pane.pane_start_command,
          pane.pane_current_path,
          preview_text,
        }, " "),
      }
    end
  end

  return prefer_active_scope_targets(agent_targets)
end

---@param window stuff.util.kitty.KittyWindow
---@param preview_text string
---@return StuffPromptAgentTarget|nil
local function get_kitty_agent_target(window, preview_text)
  preview_text = preview_text or ""
  local agent = detect_agent_name(window.window_agent_marker)
    or detect_agent_name(window.window_current_command)
    or detect_agent_name(window.window_start_command)
    or detect_agent_name(window.window_title)
    or detect_agent_name(preview_text)

  if agent == nil then return nil end

  return {
    agent = agent,
    backend = "kitty",
    id = window.window_id,
    scope_id = window.tab_id,
    scope_active = window.tab_active,
    title = window.window_title,
    current_command = window.window_current_command,
    start_command = window.window_start_command,
    current_path = window.window_current_path,
    active = window.window_active,
    preview_text = preview_text,
    text = table.concat({
      agent,
      window.window_id,
      window.window_title,
      window.window_current_command,
      window.window_start_command,
      window.window_current_path,
      preview_text,
    }, " "),
  }
end

---@param windows stuff.util.kitty.KittyWindow[]
---@param get_preview? fun(window_id: string): string
---@return StuffPromptAgentTarget[]
local function collect_kitty_agent_targets(windows, get_preview)
  local metadata_targets = {} ---@type StuffPromptAgentTarget[]
  for _, window in ipairs(windows) do
    local target = get_kitty_agent_target(window, "")
    if target ~= nil then metadata_targets[#metadata_targets + 1] = target end
  end

  local preferred_metadata_targets = prefer_active_scope_targets(metadata_targets)
  if get_preview == nil then return preferred_metadata_targets end
  for _, target in ipairs(preferred_metadata_targets) do
    if target.scope_active then return preferred_metadata_targets end
  end

  local active_scope_preview_targets = {} ---@type StuffPromptAgentTarget[]
  for _, window in ipairs(windows) do
    if window.tab_active then
      local preview_text = sanitize_preview_text(get_preview(window.window_id))
      local target = get_kitty_agent_target(window, preview_text)
      if target ~= nil then active_scope_preview_targets[#active_scope_preview_targets + 1] = target end
    end
  end

  if #active_scope_preview_targets > 0 then
    return prefer_active_scope_targets(vim.list_extend(active_scope_preview_targets, metadata_targets))
  end

  if #metadata_targets > 0 then return preferred_metadata_targets end

  local agent_targets = {} ---@type StuffPromptAgentTarget[]
  for _, window in ipairs(windows) do
    local preview_text = sanitize_preview_text(get_preview(window.window_id))
    local target = get_kitty_agent_target(window, preview_text)
    if target ~= nil then agent_targets[#agent_targets + 1] = target end
  end

  return prefer_active_scope_targets(agent_targets)
end

---@param windows stuff.util.kitty.KittyWindow[]
---@return stuff.util.kitty.KittyWindow[]
local function filter_windows_by_current_session(windows)
  local current_window_id = tostring(vim.env.KITTY_WINDOW_ID or "")
  if current_window_id == "" then return windows end

  local current_session = ""
  for _, window in ipairs(windows) do
    if window.window_id == current_window_id then
      current_session = window.session_name
      break
    end
  end

  if current_session == "" then return windows end

  local filtered = {} ---@type stuff.util.kitty.KittyWindow[]
  for _, window in ipairs(windows) do
    if window.session_name == current_session then
      filtered[#filtered + 1] = window
    end
  end

  return filtered
end

---@return StuffPromptAgentTarget[]
local function find_kitty_agent_targets()
  local kitty = require("stuff.util.kitty")
  local windows = filter_windows_by_current_session(kitty.get_windows())
  return collect_kitty_agent_targets(windows, function(window_id)
    return kitty.get_window_preview(window_id)
  end)
end

---@param backend "tmux"|"kitty"
---@return StuffPromptAgentTarget[]
function M.find(backend)
  if backend == "tmux" then return find_tmux_agent_targets() end
  return find_kitty_agent_targets()
end

M.sanitize_preview_text = sanitize_preview_text
M.prefer_active_scope_targets = prefer_active_scope_targets
M.collect_kitty_agent_targets = collect_kitty_agent_targets

return M
