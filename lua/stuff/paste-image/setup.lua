local function setup()
  vim.api.nvim_create_user_command("PasteImage", function()
    require("stuff.paste-image")()
  end, {})
end

return setup
