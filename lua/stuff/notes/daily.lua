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
  local dir = string.format("%s/daily/%d/%d", root, year, month)
  local filename = string.format("%s/%s", dir, basename)

  if vim.fn.filereadable(filename) == 0 then
    vim.fn.mkdir(dir, "p")
    local title = "# " .. os.date("%A, %B %d, %Y")

    vim.fn.writefile({ title }, filename)
  end

  return filename
end

local function jump_to_daily()
  local note = get_daily_note_filename()
  if note == "" then
    vim.notify("No weekly directory", vim.log.levels.ERROR)
    return
  end
  vim.cmd("edit " .. note)
  vim.cmd("e")
end

return {
  jump_to_daily = jump_to_daily,
}
