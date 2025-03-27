local function setup()
  vim.keymap.set("n", "<leader>jw", function()
    require("stuff.notes.weekly").jump_to_weekly()
  end, { desc = "Jump to weekly note" })
end

return setup
