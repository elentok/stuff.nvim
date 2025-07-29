local function setup()
  vim.keymap.set(
    "n",
    "<leader>jp",
    function() require("stuff.jira").preview() end,
    { desc = "Jira preview" }
  )

  vim.keymap.set(
    "n",
    "<leader>oj",
    function() require("stuff.jira").open() end,
    { desc = "Open jira" }
  )
end

return setup
