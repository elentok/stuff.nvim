---@class PromptsOptions
---@field mode? StuffPromptsMode

---@param opts PromptsOptions
local function setup(opts)
  local util = require("stuff.util")
  local config = require("stuff.prompts.config")
  util.merge_config(config, opts)

  vim.keymap.set(
    { "n" },
    "<leader>pn",
    function() require("stuff.prompts").new_for_current_line() end,
    { desc = "New AI Prompt" }
  )
  vim.keymap.set(
    { "v" },
    "<leader>pn",
    function() require("stuff.prompts").new_for_selection() end,
    { desc = "New AI Prompt" }
  )
  vim.keymap.set(
    { "n" },
    "<leader>pq",
    function() require("stuff.prompts").quick_for_current_line() end,
    { desc = "Quick AI Prompt" }
  )
  vim.keymap.set(
    { "v" },
    "<leader>pq",
    function() require("stuff.prompts").quick_for_selection() end,
    { desc = "Quick AI Prompt" }
  )
  vim.keymap.set(
    "n",
    "<leader>pp",
    function() require("stuff.prompts").toggle() end,
    { desc = "Toggle AI Prompt Window" }
  )
  vim.keymap.set(
    "n",
    "<leader>ps",
    function() require("stuff.prompts").select() end,
    { desc = "Select AI Prompt" }
  )
end

return setup
