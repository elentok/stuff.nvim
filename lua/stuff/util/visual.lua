---@class LineRange
---@field start_line number
---@field end_line number

---@return LineRange
local function get_selected_range()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  return { start_line = start_line, end_line = end_line }
end

local function get_selected_range_as_text()
  local range = get_selected_range()
  if range.start_line == range.end_line then
    return "L" .. range.start_line
  else
    return "L" .. range.start_line .. "-" .. range.end_line
  end
end

return {
  get_selected_range = get_selected_range,
  get_selected_range_as_text = get_selected_range_as_text,
}
