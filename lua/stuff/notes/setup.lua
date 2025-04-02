local function setup()
  vim.keymap.set("n", "<leader>jw", function()
    require("stuff.notes.weekly").jump_to_weekly()
  end, { desc = "Jump to weekly note" })

  vim.keymap.set("i", "<c-x>t", "- [ ]")
  vim.cmd("abbr tsk - [ ]")
end

return setup
