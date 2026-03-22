local current_prompt_win = nil
local current_prompt_buf = nil
local current_prompt_file_path = nil

local PROMPTS_DIR = vim.fs.joinpath(vim.fn.expand("~"), ".prompts")
local AGENT_NAMES = { "claude", "codex", "opencode", "cursor-agent" }
local tmux = require("stuff.util.tmux")

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
---@class StuffPromptAgentPane: TmuxPane
---@field agent string
---@field preview_text string
---@field text string

---@return StuffPromptAgentPane[]
local function find_agent_panes()
  local session = tmux.get_current_tmux_session()
  if session == nil then return {} end

  local panes = tmux.get_session_panes(session)
  local agent_panes = {} ---@type StuffPromptAgentPane[]
  for _, pane in ipairs(panes) do
    local agent = detect_agent_name(pane.pane_current_command)
      or detect_agent_name(pane.pane_start_command)
      or detect_agent_name(pane.pane_title)

    if agent ~= nil then
      local preview_text = tmux.get_pane_preview(pane.pane_id)
      agent_panes[#agent_panes + 1] = vim.tbl_extend("force", pane, {
        agent = agent,
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
      })
    end
  end

  return agent_panes
end

---@param prompt string
---@return string
local function get_sendable_prompt(prompt)
  local lines = vim.split(prompt, "\n", { plain = true })
  if lines[1] and lines[1]:match("^#%s+") then table.remove(lines, 1) end

  return vim.trim(table.concat(lines, "\n"))
end

---@param prompt string
---@param context string
---@return string
local function get_prompt_with_context(prompt, context)
  if context == "" then return prompt end

  return table.concat({ context, "", prompt }, "\n")
end

---@param pane StuffPromptAgentPane
---@param prompt string
---@return boolean
local function send_text_to_pane(pane, prompt)
  if vim.trim(prompt) == "" then
    vim.notify("Prompt is empty", vim.log.levels.WARN)
    return false
  end

  if not tmux.send_to_pane(pane.pane_id, prompt) then return false end
  if not tmux.focus_pane(pane.pane_id) then
    vim.notify("Pasted prompt but failed to focus tmux pane " .. pane.pane_id, vim.log.levels.WARN)
  end

  vim.notify(string.format("Pasted prompt to %s in pane %s", pane.agent, pane.pane_id))
  return true
end

local function send_to_tmux(text)
  if not tmux.is_inside_tmux() then
    vim.notify("Not inside a tmux session", vim.log.levels.WARN)
    return
  end

  local panes = find_agent_panes()
  if #panes == 0 then
    vim.notify("No AI agent panes found in the current tmux session", vim.log.levels.WARN)
    return
  end

  if #panes == 1 then
    send_text_to_pane(panes[1], text)
    return
  end

  Snacks.picker({
    title = "Send text to tmux pane",
    items = vim.tbl_map(
      function(pane)
        return vim.tbl_extend("force", pane, {
          preview = {
            text = pane.preview_text,
            ft = "sh",
          },
        })
      end,
      panes
    ),
    preview = "preview",
    format = function(item, _picker)
      local ret = {}
      local label_hl = item.pane_active and "DiagnosticOk" or "DiagnosticHint"
      local title = item.pane_title ~= "" and item.pane_title or item.pane_current_command
      local path = item.pane_current_path ~= "" and item.pane_current_path or "[no path]"

      table.insert(ret, { " " .. item.agent .. " ", "DiagnosticInfo" })
      table.insert(ret, { " " .. item.pane_id .. " ", label_hl })
      table.insert(ret, { " " .. title })
      table.insert(ret, { "  " .. path, "Comment" })

      return ret
    end,
    confirm = function(picker, item)
      picker:close()
      send_text_to_pane(item, text)
    end,
  })
end

local function send_current_prompt_to_tmux()
  local lines = vim.api.nvim_buf_get_lines(current_prompt_buf, 0, -1, false)
  local prompt = get_sendable_prompt(table.concat(lines, "\n"))
  send_to_tmux(prompt)
end

---@param context string
local function quick(context)
  vim.ui.input({ prompt = "Quick prompt: " }, function(input)
    if input == nil then return end

    local prompt = vim.trim(input)
    if prompt == "" then
      vim.notify("Prompt is empty", vim.log.levels.WARN)
      return
    end

    send_to_tmux(get_prompt_with_context(prompt, context))
  end)
end

local function get_prompt_file_path(description)
  local date = os.date("%Y-%m-%d")
  local time = os.date("%H%M")
  local dir = vim.fs.joinpath(PROMPTS_DIR, date)
  vim.fn.mkdir(dir, "p")
  return vim.fs.joinpath(dir, string.format("%s-%s.md", time, description))
end

---@param description string
---@param context string
local function get_initial_content(description, context)
  local content = { "# " .. description }
  if context ~= "" then
    table.insert(content, "")
    table.insert(content, context)
  end

  return table.concat(content, "\n")
end

---@param suffix string
---@return string
local function get_file_context(suffix)
  local filename = vim.fn.expand("%:.")
  if filename == "" then return "" end

  return string.format("@%s %s", filename, suffix)
end

local function close_window()
  if current_prompt_win ~= nil then
    if vim.api.nvim_win_is_valid(current_prompt_win) then
      vim.api.nvim_win_close(current_prompt_win, true)
    end
  end
  current_prompt_win = nil
end

local function delete_buffer()
  if current_prompt_buf ~= nil then
    vim.api.nvim_buf_delete(current_prompt_buf, {
      force = true,
    })
    current_prompt_buf = nil
  end

  current_prompt_file_path = nil
end

---@param file_path string
---@return integer win_handle
local function open_prompt(file_path)
  close_window()

  local basename = vim.fs.basename(file_path)
  local win = require("stuff.util.float").open_float({
    title = "Prompt: " .. basename,
    filename = file_path,
  })

  current_prompt_file_path = file_path
  current_prompt_win = win
  current_prompt_buf = vim.api.nvim_win_get_buf(win)

  vim.keymap.set("n", "q", ":close<cr>", {
    buffer = current_prompt_buf,
  })
  vim.keymap.set("n", "<leader>r", send_current_prompt_to_tmux, {
    buffer = current_prompt_buf,
    desc = "Send prompt to tmux AI agent",
  })

  return win
end

---@param description string
---@param context string
---@return string|nil returns file_path when successful, nil if failed
local function write_prompt_file(description, context)
  local file_path = get_prompt_file_path(description)
  local initial_content = get_initial_content(description, context)

  -- Write initial content to the file
  local file = io.open(file_path, "w")
  if file then
    file:write(initial_content)
    file:close()
  else
    vim.notify("Could not create prompt file: " .. file_path, vim.log.levels.ERROR)
    return
  end

  return file_path
end

---@param context string
local function new(context)
  vim.ui.input({ prompt = "Prompt description: ", completion = "file" }, function(description)
    if not description or description:gsub("%s+", "") == "" then
      vim.notify("Prompt description cannot be empty", vim.log.levels.WARN)
      return
    end

    local file_path = write_prompt_file(description, context)
    if file_path == nil then return end

    close_window()
    delete_buffer()
    open_prompt(file_path)
  end)
end

local function new_for_selection()
  local range = require("stuff.util.visual").get_visual_range_as_text()
  local context = get_file_context(range)
  return new(context)
end

local function new_for_current_line()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local context = get_file_context(string.format("L%d", lnum))
  return new(context)
end

local function quick_for_selection()
  local range = require("stuff.util.visual").get_visual_range_as_text()
  local context = get_file_context(range)
  return quick(context)
end

local function quick_for_current_line()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local context = get_file_context(string.format("L%d", lnum))
  return quick(context)
end

local function toggle()
  if not current_prompt_buf or not vim.api.nvim_buf_is_valid(current_prompt_buf) then
    vim.notify("No active prompt", vim.log.levels.INFO)
    return
  end

  local is_visible = false
  if current_prompt_win and vim.api.nvim_win_is_valid(current_prompt_win) then
    local bufnr_in_win = vim.api.nvim_win_get_buf(current_prompt_win)
    if bufnr_in_win == current_prompt_buf then is_visible = true end
  end

  if is_visible then
    close_window()
  elseif current_prompt_file_path ~= nil then
    open_prompt(current_prompt_file_path)
  end
end

local function select()
  Snacks.picker({
    finder = "files",
    dirs = { PROMPTS_DIR },
    ft = "md",
    prompt = "Select Prompt:",
    confirm = function(picker, item)
      picker:close()

      close_window()
      delete_buffer()
      open_prompt(item.file)
    end,
  })
end

return {
  new_for_current_line = new_for_current_line,
  new_for_selection = new_for_selection,
  quick_for_current_line = quick_for_current_line,
  quick_for_selection = quick_for_selection,
  select = select,
  send_to_tmux = send_current_prompt_to_tmux,
  toggle = toggle,
}
