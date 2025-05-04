local float = require("stuff.util.float")

local function open_messages_buffer()
  float.open_float({
    title = "Messages",
  })

  -- vim.cmd("new")
  vim.cmd("noswapfile hide enew")
  vim.cmd("put = execute('message')")

  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "hide"
  vim.bo.modifiable = false
  vim.cmd("file Messages")

  vim.keymap.set("n", "q", ":bd<cr>", { buffer = true, noremap = true, silent = true })
end

return { open_messages_buffer = open_messages_buffer }
