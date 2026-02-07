local function setup()
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
