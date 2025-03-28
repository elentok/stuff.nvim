---@class LogLineOptions
---@field prefix? string

---@param opts? LogLineOptions
local function setup(opts)
  local config = require("stuff.log-line.config")
  require("stuff.util").merge_config(config, opts)

  vim.keymap.set("i", "<c-l>", function()
    require("stuff.log-line").insert_log_line()
  end)
end

return setup
