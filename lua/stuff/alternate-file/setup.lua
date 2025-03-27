local function setup()
  vim.keymap.set("n", "<leader>jo", function()
    require("stuff.alternate-file").goto_alternate_file()
  end, { desc = "Jump between code and test" })
end

return setup
