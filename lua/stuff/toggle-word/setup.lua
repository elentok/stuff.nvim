---@class ToggleWordOptions
---@field key? string|boolean
---@field debug? boolean
---@field register? string
---@field values? { [string]: string }

---@param opts ToggleWordOptions
local function setup(opts)
  local util = require("stuff.util")
  local config = require("stuff.toggle-word.config")
  util.merge_config(config, opts)

  -- add the reverse + uppercase mappings to the hash
  for value, opposite in pairs(config.values) do
    config.values[opposite] = value

    local upper_value = value:upper()
    local upper_opposite = opposite:upper()
    config.values[upper_value] = upper_opposite
    config.values[upper_opposite] = upper_value
  end

  local key = config.key
  if type(key) == "string" then
    vim.keymap.set("n", key, function()
      require("stuff.toggle-word").toggle_word()
    end, { desc = "Toggle word" })
  end
end

return setup
