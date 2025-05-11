local function setup()
  vim.keymap.set(
    "n",
    "<leader>to",
    function() require("stuff.typescript.toggle-only")() end,
    { desc = "Toggle .only on closest test" }
  )

  vim.keymap.set(
    "n",
    "<leader>ta",
    function() require("stuff.typescript.toggle-async")() end,
    { desc = "Toggle async on closest function" }
  )

  vim.api.nvim_create_user_command("TsServerLog", function()
    local client = require("stuff.util.lsp").get_buf_client("vtsls")
    if client ~= nil then
      client:exec_cmd({ command = "typescript.openTsServerLog", title = "Open TS Server Log" })
    end
  end, {})
end

return setup
