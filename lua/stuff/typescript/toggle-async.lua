---Replace part of a line in the buffer
---@param start_row integer
---@param start_col integer
---@param end_col integer
---@param new_text string
local function replace_text_on_line(start_row, start_col, end_col, new_text)
  local line = vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)[1]
  local new_line = line:sub(1, start_col) .. new_text .. line:sub(end_col + 1)
  vim.api.nvim_buf_set_lines(0, start_row, start_row + 1, false, { new_line })
end

---Toggle 'async' before the given function node
---@param node TSNode
local function toggle_async_on_node(node)
  local start_row, start_col = node:range()
  local text = vim.treesitter.get_node_text(node, 0)

  -- For `async function`, remove async
  if text:match("^async%s+") then
    local async_len = #"async "
    replace_text_on_line(start_row, start_col, start_col + async_len - 1, "")
    vim.notify("Removed 'async'", "info")
    return
  end

  -- Add `async ` before the function or arrow expression
  if node:type() == "function" or node:type() == "function_declaration" then
    replace_text_on_line(start_row, start_col, start_col - 1, "async ")
    vim.notify("Added 'async'", "info")
  elseif node:type() == "arrow_function" then
    replace_text_on_line(start_row, start_col, start_col - 1, "async ")
    vim.notify("Added 'async'", "info")
  else
    vim.notify("Unsupported function type: " .. node:type(), "error")
  end
end

---Find the nearest function node upward and toggle 'async'
local function toggle_async_on_nearest_function()
  local ts_utils = require("nvim-treesitter.ts_utils")
  local node = ts_utils.get_node_at_cursor()
  if not node then return end

  while node do
    local t = node:type()
    if t == "function" or t == "function_declaration" or t == "arrow_function" then
      toggle_async_on_node(node)
      return
    end
    node = node:parent()
  end

  vim.notify("No enclosing function found.", "warn")
end

return toggle_async_on_nearest_function
