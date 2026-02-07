local function setup()
  vim.keymap.set(
    "n",
    "<leader>yf",
    function() require("stuff.yank").yank_filename() end,
    { desc = "Yank current filename" }
  )

  vim.keymap.set(
    "v",
    "<leader>yf",
    function() require("stuff.yank").yank_filename_with_visual_range() end,
    { desc = "Yank current filename with line numbers" }
  )

  vim.keymap.set(
    "v",
    "<leader>ym",
    function() require("stuff.yank").yank_markdown() end,
    { desc = "Yank markdown" }
  )

  vim.keymap.set(
    "n",
    "<leader>ya",
    function() require("stuff.yank").yank_all_file() end,
    { desc = "Yank entire file (all)" }
  )
end

return setup
