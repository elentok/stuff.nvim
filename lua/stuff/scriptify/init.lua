---@param lang string
---@return nil|string[]
local function hashtag_lines(lang)
  local config = require("stuff.scriptify.config")
  local hashtag = config.hashtags[lang]
  if hashtag == nil then
    return nil
  end

  if type(hashtag) == "string" then
    return vim.split(hashtag, "\n")
  end

  return hashtag
end

local function scriptify(lang)
  local header_lines = hashtag_lines(lang)
  if header_lines == nil then
    print("Unknown hashtag for language '" .. lang .. "'")
    return
  end

  table.insert(header_lines, "")

  vim.api.nvim_buf_set_lines(0, 0, 0, true, header_lines)
  vim.cmd("write")
  vim.fn.system("chmod u+x " .. vim.fn.shellescape(vim.fn.expand("%")))
  vim.cmd("e!")
end

local function open()
  local config = require("stuff.scriptify.config")
  vim.ui.select(vim.tbl_keys(config.hashtags), {
    prompt = "Scriptify - select hashtag:",
  }, function(choice)
    if choice ~= nil then
      scriptify(choice)
    end
  end)
end

return {
  open = open,
  scriptify = scriptify,
}
