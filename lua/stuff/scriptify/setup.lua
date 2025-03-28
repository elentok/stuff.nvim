---@class ScriptifyOptions
---@field hashtags? { [string]: string|string[] }

---@param opts? ScriptifyOptions
local function setup(opts)
  local config = require("stuff.scriptify.config")
  require("stuff.util").merge_config(config, opts)

  vim.keymap.set("n", "<leader>sf", function()
    require("stuff.scriptify").open()
  end, { desc = "Scriptify" })

  vim.api.nvim_create_user_command("Scriptify", function()
    require("stuff.scriptify").open()
  end, {})
end

return setup
