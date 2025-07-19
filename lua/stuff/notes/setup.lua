local function setup()
  vim.keymap.set(
    "n",
    "<leader>jw",
    function() require("stuff.notes.weekly").jump_to_weekly() end,
    { desc = "Jump to weekly note" }
  )

  vim.keymap.set("i", "<c-x>t", "- [ ]")
  vim.cmd("abbr tsk - [ ]")
  vim.keymap.set(
    "n",
    "<leader>tt",
    function() require("stuff.notes.tasks").toggle_done() end,
    { desc = "Toggle task done" }
  )

  vim.keymap.set(
    "i",
    "<c-x>m",
    function() require("stuff.notes.insert-link").insert_link() end,
    { desc = "Insert markdown link" }
  )
  vim.keymap.set(
    "n",
    "<leader>il",
    function() require("stuff.notes.insert-link").insert_link() end,
    { desc = "Insert markdown link" }
  )
  vim.keymap.set(
    "n",
    "<leader>ii",
    function() require("stuff.notes.insert-image").insert_image() end,
    { desc = "Insert markdown image" }
  )
end

return setup
