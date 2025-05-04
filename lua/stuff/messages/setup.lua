local function setup()
  vim.keymap.set(
    "n",
    "<leader>wm",
    require("stuff.messages").open_messages_buffer,
    { desc = "Show messages" }
  )
end

return setup
