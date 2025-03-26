local function extendVimUiOpen()
  local originalOpen = vim.ui.open
  vim.ui.open = function(path)
    local expand = require("stuff.open-link.expand")
    return originalOpen(expand(path))
  end

  vim.keymap.set("n", "gx", "<cmd>OpenLink<cr>")
end

return extendVimUiOpen
