---@class ToggleWordConfig
---@field key string|boolean
---@field debug boolean
---@field register string
---@field values { [string]: string }

---@type ToggleWordConfig
local config = {
  -- Set "key" to false when calling in order to disable the keymapping.
  key = "<leader>tw",
  debug = false,
  register = "t",
  values = {
    ["true"] = "false",
    ["True"] = "False",
    ["yes"] = "no",
    ["on"] = "off",
    ["enabled"] = "disabled",
    ["enable"] = "disable",
    ["left"] = "right",
    ["top"] = "bottom",
    ["should"] = "should_not",
    ["be_true"] = "be_false",
    ["border-left"] = "border-right",
    ["border-top"] = "border-bottom",
    ["margin-left"] = "margin-right",
    ["margin-top"] = "margin-bottom",
    ["padding-left"] = "padding-right",
    ["padding-top"] = "padding-bottom",
    ["addClass"] = "removeClass",
    ["column"] = "row",
    ["back"] = "fwd",
    ["up"] = "down",
    ["const"] = "let",
    ["dark"] = "light",
    ["+"] = "-",
  },
}

return config
