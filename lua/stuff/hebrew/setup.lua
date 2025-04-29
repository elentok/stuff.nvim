local function setup()
  vim.keymap.set("n", "<space>h", function()
    require("stuff.hebrew").toggle_hebrew()
  end, { desc = "Toggle hebrew" })
end

return setup
