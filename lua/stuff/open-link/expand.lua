local config = require("stuff.open-link.config")
local helpers = require("stuff.open-link.helpers")

---@param link string
local function expand(link)
  for _, expander in ipairs(config.expanders) do
    local expanded_link = expander(link)

    if expanded_link ~= nil then
      link = expanded_link
    end
  end

  if not helpers.is_http_or_file_link(link) then
    local path_to_file = helpers.find_abs_path(link)
    if path_to_file ~= nil then
      return path_to_file
    end
  end

  return link
end

return expand
