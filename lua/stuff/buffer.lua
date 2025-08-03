local function delete_current_file()
  local bufname = vim.api.nvim_buf_get_name(0)

  if not require("stuff.util.ui").confirm("Delete " .. bufname .. "?") then return end

  vim.api.nvim_buf_delete(0, {})
  vim.fs.rm(bufname)
end

local function setup()
  vim.keymap.set("n", "<leader>df", delete_current_file, { desc = "Delete current file" })
end

return setup
