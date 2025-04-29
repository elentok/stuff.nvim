local function setup()
  vim.api.nvim_create_user_command("PasteImage", function() require("stuff.paste-image")() end, {})

  vim.keymap.set("n", "<Leader>ip", "<cmd>PasteImage<cr>", { desc = "Paste image from clipboard" })
end

return setup
