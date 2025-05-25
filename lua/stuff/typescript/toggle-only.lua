---Determine if the function name is a test block we care about
---@param text string
---@return boolean
local function is_test_node(text)
  return text == "it" or text == "describe" or text == "it.only" or text == "describe.only"
end

---Return the toggled form of the test block function name
---@param text string
---@return string|nil
local function get_toggled_name(text)
  if text == "it" or text == "test" or text == "describe" then
    return text .. ".only"
  elseif text == "it.only" or text == "test.only" or text == "describe.only" then
    return (text:gsub("%.only", ""))
  end
  return nil
end

---Replace the text of a node in the current buffer
---@param node TSNode
---@param new_text string
local function replace_node_text(node, new_text)
  -- _ = end_row
  local start_row, start_col, _, end_col = node:range()
  local line = vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)[1]
  local before = line:sub(1, start_col)
  local after = line:sub(end_col + 1)
  local new_line = before .. new_text .. after
  vim.api.nvim_buf_set_lines(0, start_row, start_row + 1, false, { new_line })
end

local function toggle_only_on_nearest_test()
  local node = vim.treesitter.get_node()
  if not node then return end

  while node do
    if node:type() == "call_expression" then
      local func_node = node:child(0)
      if func_node then
        local text = vim.treesitter.get_node_text(func_node, 0)
        if is_test_node(text) then
          local toggled = get_toggled_name(text)
          if toggled then
            replace_node_text(func_node, toggled)
            vim.notify("Toggled to: " .. toggled, "info")
            return
          end
        end
      end
    end
    node = node:parent()
  end

  vim.notify("No enclosing 'it' or 'describe' found.", "warn")
end

return toggle_only_on_nearest_test
