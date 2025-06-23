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
end

return setup
