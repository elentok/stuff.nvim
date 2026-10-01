local function extendVimUiOpen()
  local originalOpen = vim.ui.open
  vim.ui.open = function(path)
    local expand = require("stuff.open-link.expand")
    return originalOpen(expand(path))
  end
end

return extendVimUiOpen
