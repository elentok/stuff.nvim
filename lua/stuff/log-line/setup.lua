---@class LogLineOptions
---@field prefix? string
---@field key? string

---@param opts? LogLineOptions
local function setup(opts)
  local config = require("stuff.log-line.config")
  require("stuff.util").merge_config(config, opts)

  if config.key ~= nil then
    vim.keymap.set("i", config.key, function()
      require("stuff.log-line").insert_log_line()
    end)
  end
end

return setup
