local function setup()
  vim.keymap.set(
    "n",
    "<leader>to",
    function() require("stuff.testing.toggle-only")() end,
    { desc = "Toggle .only on closest test" }
  )
end

return setup
