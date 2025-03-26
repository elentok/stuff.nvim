---@param ... LinkExpander[]
local function add_expanders(...)
  local config = require("stuff.open-link.config")

  vim.list_extend(config.expanders, { ... })
end

---@param ... LinkExpander[]
local function prepend_expanders(...)
  local config = require("stuff.open-link.config")
  config.expanders = vim.list_extend({ ... }, config.expanders)
end

return {
  add_expanders = add_expanders,
  prepend_expanders = prepend_expanders,
}
