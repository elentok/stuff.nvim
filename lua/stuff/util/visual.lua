---@class LineRange
---@field start_line number
---@field end_line number

---@return LineRange
local function get_visual_range()
  local mode = vim.fn.mode(1)
  local start_line
  local end_line

  if mode:match("^[vV\22]") then
    start_line = vim.fn.getpos("v")[2]
    end_line = vim.fn.getpos(".")[2]
  else
    start_line = vim.fn.getpos("'<")[2]
    end_line = vim.fn.getpos("'>")[2]
  end

  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  return { start_line = start_line, end_line = end_line }
end

local function get_visual_range_as_text()
  local range = get_visual_range()
  if range.start_line == range.end_line then
    return "L" .. range.start_line
  else
    return "L" .. range.start_line .. "-" .. range.end_line
  end
end

---@return string[]
local function get_lines()
  local range = get_visual_range()

  return vim.api.nvim_buf_get_lines(0, range.start_line - 1, range.end_line, false)
end

return {
  get_visual_range = get_visual_range,
  get_visual_range_as_text = get_visual_range_as_text,
  get_lines = get_lines,
}
