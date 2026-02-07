local current_prompt_win = nil
local current_prompt_buf = nil
local current_prompt_file_path = nil

local PROMPTS_DIR = vim.fs.joinpath(vim.fn.expand("~"), ".prompts")

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
  local content = { "# " .. description, "", context }
  return table.concat(content, "\n")
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
    current_prompt_buf = true
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
  local filename = vim.fn.expand("%:.")
  local context = string.format("@%s %s", filename, range)
  return new(context)
end

local function new_for_current_line()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local filename = vim.fn.expand("%:.")
  local context = string.format("@%s L%d", filename, lnum)
  return new(context)
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
  select = select,
  toggle = toggle,
}
