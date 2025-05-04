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

return { action = action }
