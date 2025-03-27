local expand = require("stuff.open-link.expand")
local helpers = require("stuff.open-link.helpers")

---@param link? string
local function open(link)
  if link == nil then
    link = vim.fn.expand("<cfile>")
  end

  if vim.regex("^\\s*$"):match_str(link) then
    vim.notify("No link was found at the cursor.", vim.log.levels.WARN)
    return
  end

  link = expand(link)

  if not helpers.is_http_or_file_link(link) then
    link = "http://" .. link
  end

  local browse = require("stuff.util.browse")
  browse(link)
end

return open
