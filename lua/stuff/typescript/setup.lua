local function setup()
  vim.keymap.set(
    "n",
    "<leader>to",
    function() require("stuff.typescript.toggle-only").toggle_only_on_nearest_test() end,
    { desc = "Toggle .only on closest test" }
  )
end

return setup
