local function setup()
  vim.keymap.set("n", "<leader>ga", function()
    require("stuff.git.file").add_with_patch()
  end, { desc = "Git add file (patch)" })

  vim.keymap.set("n", "<leader>gu", function()
    require("stuff.git.file").checkout_with_patch()
  end, { desc = "Git checkout file (patch)" })

  vim.keymap.set("n", "<leader>gw", function()
    require("stuff.git.file").write_and_stage()
  end, { desc = "Write + Stage" })

  vim.keymap.set("n", "<leader>gr", function()
    require("stuff.git.file").reset_changes()
  end, { desc = "Reset git changes" })

  vim.keymap.set("n", "<leader>gy", function()
    require("stuff.git.url").yank()
  end, { desc = "Git yank URL" })

  vim.keymap.set("n", "<leader>go", function()
    require("stuff.git.url").open()
  end, { desc = "Git open URL" })
end

return setup
