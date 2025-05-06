local function setup()
  vim.keymap.set(
    "n",
    "<leader>to",
    function() require("stuff.typescript.toggle-only")() end,
    { desc = "Toggle .only on closest test" }
  )

  vim.keymap.set(
    "n",
    "<leader>ta",
    function() require("stuff.typescript.toggle-async")() end,
    { desc = "Toggle async on closest function" }
  )
end

return setup
