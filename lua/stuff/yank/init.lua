---@class YankOpts
---@field quiet? boolean do not notify about the yank

---@param text string
---@param opts? YankOpts
local function yank(text, opts)
  vim.fn.setreg("+", text)

  if opts == nil or opts.quiet ~= true then
    if #text > 100 then
      vim.notify("  Copied " .. #text .. " characters")
    else
      vim.notify("  Copied " .. vim.trim(text))
    end
  end
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

local function yank_all_file()
  vim.cmd("normal! myggVGy`y")
  local line_count = vim.api.nvim_buf_line_count(0)
  vim.notify("  Copied entire file (" .. line_count .. " lines)")
end

local function yank_markdown()
  local script_dir = require("stuff.util.path").current_script_dir()
  local dprint_config = vim.fs.joinpath(script_dir, "dprint-markdown.json")

  local lines = require("stuff.util.visual").get_lines()

  local shell = require("stuff.util.shell")
  local result = shell("dprint", {
    args = {
      "fmt",
      "--config",
      dprint_config,
      "--stdin",
      "file.md", -- so dprint knows it should format markdown
    },
    stdin = lines,
  })

  if result.code ~= 0 then return end

  yank(result.stdout)
end

return {
  yank = yank,
  yank_filename = yank_filename,
  yank_filename_with_visual_range = yank_filename_with_visual_range,
  yank_markdown = yank_markdown,
  yank_all_file = yank_all_file,
}
