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

---@param md_lines string[]
---@return string|nil
local function md2html(md_lines)
  local shell = require("stuff.util.shell")
  local pandoc_result = shell("pandoc", {
    args = {
      "--from=markdown",
      "--to=html",
      "--standalone",
    },
    stdin = table.concat(md_lines, "\n"),
  })

  if pandoc_result.code ~= 0 then
    vim.notify(
      "Error converting markdown to HTML with pandoc: " .. pandoc_result.stderr,
      vim.log.levels.ERROR
    )
    return nil
  end

  return pandoc_result.stdout
end

---@param html string
---@return string|nil
local function html2rtf(html)
  local shell = require("stuff.util.shell")
  local textutil_result = shell("textutil", {
    args = {
      "-stdin",
      "-format",
      "html",
      "-convert",
      "rtf",
      "-stdout",
    },
    stdin = html,
  })

  if textutil_result.code ~= 0 then
    vim.notify(
      "Error converting HTML to RTF with textutil: " .. textutil_result.stderr,
      vim.log.levels.ERROR
    )
    return
  end

  return textutil_result.stdout
end

local function yank_html()
  local lines = require("stuff.util.visual").get_lines()
  local html = md2html(lines)
  if html == nil then return end
  local rtf = html2rtf(html)
  if rtf == nil then return end
  yank(rtf)
end

return {
  yank = yank,
  yank_filename = yank_filename,
  yank_filename_with_visual_range = yank_filename_with_visual_range,
  yank_markdown = yank_markdown,
  yank_all_file = yank_all_file,
  yank_html = yank_html,
}
