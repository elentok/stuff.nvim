---@param name string
local function action(name)
  vim.lsp.buf.code_action({
    apply = true,
    context = {
      only = { name },
      diagnostics = {},
    },
  })
end

--- Get
---@param name string
---@return vim.lsp.Client|nil
local function get_buf_client(name)
  local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf(), name = name })
  if #clients == 0 then
    vim.notify("No LSP client named " .. name, vim.log.levels.WARN)
    return nil
  end
  return clients[1]
end

return { action = action, get_buf_client = get_buf_client }
