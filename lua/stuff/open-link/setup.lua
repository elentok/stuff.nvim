---@class OpenLinkOptions
---@field expanders? LinkExpander[] Replaces all of the expanders
---@field extend_vim_ui_open? boolean Wrap vim.ui.open (default = true)

---@param opts OpenLinkOptions
local function setup(opts)
  local util = require("stuff.util")
  local config = require("stuff.open-link.config")
  util.merge_config(config, opts)

  if opts.extend_vim_ui_open ~= false then
    require("stuff.open-link.extend-vim-ui-open")()
  end

  vim.api.nvim_create_user_command("OpenLink", function()
    require("stuff.open-link.open")()
  end, {})
end

return setup
