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
  local additions = {}
  for value, opposite in pairs(config.values) do
    additions[opposite] = value

    local upper_value = value:upper()
    local upper_opposite = opposite:upper()
    additions[upper_value] = upper_opposite
    additions[upper_opposite] = upper_value
  end

  for k, v in pairs(additions) do
    config.values[k] = v
  end

  local key = config.key
  if type(key) == "string" then
    vim.keymap.set(
      "n",
      key,
      function() require("stuff.toggle-word").toggle_word() end,
      { desc = "Toggle word" }
    )
  end
end

return setup
