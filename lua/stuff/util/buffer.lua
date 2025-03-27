---@return boolean
local function is_unsaved()
  return vim.api.nvim_buf_get_name(0) == ""
end

---@return boolean
local function is_in_cwd()
  local current_file = vim.fn.expand("%:p")
  local cwd = vim.fn.getcwd()

  -- Check if the current file path starts with the cwd
  return string.sub(current_file, 1, #cwd) == cwd
end

return {
  is_unsaved = is_unsaved,
  is_in_cwd = is_in_cwd,
}
