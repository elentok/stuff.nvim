-- format as "# Sun, Sep 14, 2025"
local daily_header_format = "# %a, %b %d, %Y"

---@param root string | nil
---@return string
local function get_daily_note_filename(root)
  if root == nil then root = vim.uv.cwd() end

  local date = os.date("%Y-%m-%d")
  local year = os.date("%Y")
  local month = os.date("%m")

  local basename = date .. ".md"
  ---@cast basename string
  basename = basename:lower()
  local dir = string.format("%s/daily/%s/%s", root, year, month)
  local filename = string.format("%s/%s", dir, basename)

  if vim.fn.filereadable(filename) == 0 then
    vim.fn.mkdir(dir, "p")
    local title = os.date(daily_header_format)

    vim.fn.writefile({ title }, filename)
  end

  return filename
end

---@param root_dir string | nil
local function jump_to_daily(root_dir)
  local note = get_daily_note_filename(root_dir)
  if note == "" then
    vim.notify("No weekly directory", vim.log.levels.ERROR)
    return
  end
  vim.cmd("edit " .. note)
end

local function insert_date_header()
  -- Get current filename without path
  local filename = vim.fn.expand("%:t")

  -- strip the extension
  local date_str = filename:gsub("%.md$", "")

  -- parse using strptime
  local date = vim.fn.strptime("%Y-%m-%d", date_str)
  if date == 0 then
    print("Filename is not a valid YYYY-MM-DD.md date")
    return
  end

  local header = vim.fn.strftime(daily_header_format, date)

  -- insert at the top
  vim.api.nvim_buf_set_lines(0, 0, 0, false, { header, "" })
end

return {
  jump_to_daily = jump_to_daily,
  insert_date_header = insert_date_header,
  get_daily_note_filename = get_daily_note_filename,
}
