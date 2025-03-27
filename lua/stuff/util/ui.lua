---@param msg string
---@return boolean
local function confirm(msg)
  return vim.fn.confirm(msg, "&Yes\n&No") == 1
end

return {
  confirm = confirm,
}
