local function setup()
  vim.keymap.set("n", "<leader>ga", function()
    require("stuff.git").add_file_patch()
  end, { desc = "Git add file (patch)" })

  vim.keymap.set("n", "<leader>gu", function()
    require("stuff.git").checkout_file_patch()
  end, { desc = "Git checkout file (patch)" })

  vim.keymap.set("n", "<leader>gw", function()
    require("stuff.git").write_and_add_file()
  end, { desc = "Write + Stage" })

  vim.keymap.set("n", "<leader>gr", function()
    require("stuff.git").reset_file_changes()
  end, { desc = "Reset git changes" })
end

return setup
