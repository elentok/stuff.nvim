---@param msg string
---@return boolean
local function confirm(msg)
  return vim.fn.confirm(msg, "&Yes\n&No") == 1
end

---@param keys string
local function feedkeys(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", true)
end

return {
  confirm = confirm,
  feedkeys = feedkeys,
}
