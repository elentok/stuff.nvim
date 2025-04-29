local function setup()
  -- Duplicate and Comment
  vim.keymap.set(
    "n",
    "<leader>yc",
    table.concat({
      '"zyy', -- yank
      "gcc", -- comment
      '"zp', -- paste
    }),
    { remap = true, desc = "Duplicate and comment" }
  )

  vim.keymap.set(
    "v",
    "<leader>yc",
    table.concat({
      '"zy', -- yank
      "gv", -- re-select
      "gc", -- comment
      "']", -- go to end of block
      '"zp', -- paste
    }),
    { remap = true, desc = "Duplicate and comment" }
  )
end

return setup
