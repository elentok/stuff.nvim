local function setup()
  vim.o.foldmethod = "expr"

  -- In Neovim 0.10 and above a blank string shows the first line of the folded block with syntax highlighting
  vim.o.foldtext = ""

  -- Default to treesitter folding
  vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

  -- Prefer LSP folding if client supports it
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client ~= nil and client:supports_method("textDocument/foldingRange") then
        local win = vim.api.nvim_get_current_win()
        vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
      end
    end,
  })
end

return setup
