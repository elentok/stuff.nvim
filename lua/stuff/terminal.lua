local function setup()
  vim.keymap.set(
    { "n", "t" },
    "<c-q>",
    function() Snacks.terminal.toggle(vim.o.shell, { win = { border = "rounded" } }) end
  )
end

return setup
