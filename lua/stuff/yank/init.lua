---@param text string
local function yank(text)
  vim.fn.setreg("+", text)
  vim.notify("Copied " .. text)
end

local function yank_filename()
  local filename = vim.fn.expand("%:.")
  yank(filename)
end

local function yank_filename_with_visual_range()
  local filename = vim.fn.expand("%:.")
  local range = require("stuff.util.visual").get_visual_range_as_text()
  local value = filename .. " " .. range
  yank(value)
  require("stuff.util.ui").feedkeys("<Esc>")
end

return {
  yank = yank,
  yank_filename = yank_filename,
  yank_filename_with_visual_range = yank_filename_with_visual_range,
}
