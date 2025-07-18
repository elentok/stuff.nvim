local function setup()
  vim.keymap.set(
    "n",
    "<leader>jw",
    function() require("stuff.notes.weekly").jump_to_weekly() end,
    { desc = "Jump to weekly note" }
  )

  vim.keymap.set("i", "<c-x>t", "- [ ]")
  vim.keymap.set("i", "<c-x>m", function() require("stuff.notes.insert-link").insert_link() end)
  vim.keymap.set("n", "<leader>il", function() require("stuff.notes.insert-link").insert_link() end)
  vim.cmd("abbr tsk - [ ]")
  vim.keymap.set(
    "n",
    "<leader>tt",
    function() require("stuff.notes.tasks").toggle_done() end,
    { desc = "Toggle task done" }
  )
end

return setup
