local map = vim.keymap.set

local function setup()
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      map(
        "n",
        "<leader>co",
        function() require("stuff.util.lsp").action("source.organizeImports") end,
        { desc = "Organize imports", buffer = args.buf }
      )

      map(
        "n",
        "gd",
        function() Snacks.picker.lsp_definitions() end,
        { desc = "Go to definition", buffer = args.buf }
      )

      -- vim.keymap.del("n", "K")
      map(
        "n",
        "K",
        function() vim.lsp.buf.hover({ border = "rounded" }) end,
        { desc = "Show LSP hover", buffer = args.buf }
      )
    end,
  })

  vim.api.nvim_create_user_command("LspRestart", function()
    vim.lsp.stop_client(vim.lsp.get_clients({ bufnr = 0 }), true)
    vim.cmd("edit")
  end, {})
end

return setup
