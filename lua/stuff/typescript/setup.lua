local function setup()
  vim.keymap.set(
    "n",
    "<leader>ta",
    function() require("stuff.typescript.toggle-async")() end,
    { desc = "Toggle async on closest function" }
  )

  vim.keymap.set("n", "<leader>un", function()
    vim.defer_fn(function() require("stuff.typescript.npm-upgrade").npm_upgrade() end, 1)
  end, { desc = "Upgrade npm package version" })

  vim.api.nvim_create_user_command("TsServerLog", function()
    local client = require("stuff.util.lsp").get_buf_client("vtsls")
    if client ~= nil then
      client:exec_cmd({ command = "typescript.openTsServerLog", title = "Open TS Server Log" })
    end
  end, {})
end

return setup
