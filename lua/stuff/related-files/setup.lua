local function setup()
  local related = require("stuff.related-files")

  vim.keymap.set(
    "n",
    "<leader>jj",
    function() related.jump_to_related(nil) end,
    { desc = "Jump to related file (picker)" }
  )

  vim.keymap.set(
    "n",
    "<leader>jtt",
    function() related.jump_to_related("test") end,
    { desc = "Jump to test file" }
  )

  vim.keymap.set(
    "n",
    "<leader>jtc",
    function() related.jump_to_related("code") end,
    { desc = "Jump to code file" }
  )

  vim.keymap.set(
    "n",
    "<leader>jts",
    function() related.jump_to_related("style") end,
    { desc = "Jump to style file" }
  )
end

return setup
