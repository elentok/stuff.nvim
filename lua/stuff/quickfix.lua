local function setup()
  vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "qf",
    callback = function(args) vim.keymap.set("n", "q", ":q<cr>", { buffer = args.buf }) end,
  })
end

return setup
