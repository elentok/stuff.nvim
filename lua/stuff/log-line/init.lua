local function get_logger_line()
  local config = require("stuff.log-line.config")

  local context = "L" .. vim.fn.line(".")
  local filename = vim.fn.expand("%:t")

  local log = config.prefix .. " [" .. filename .. "] " .. context

  local filetype = vim.bo.filetype
  if filetype == "typescript" or filetype == "typescriptreact" or filetype == "javascript" then
    return "console.log('" .. log .. "')"
  elseif filetype == "lua" then
    return "put('" .. log .. "')"
  elseif filetype == "sh" then
    return 'echo "' .. log .. '"'
  else
    return ""
  end
end

local function insert_log_line()
  vim.api.nvim_put({ get_logger_line() }, "c", true, true)
  require("stuff.util.ui").feedkeys("<Left>")
end

return { insert_log_line = insert_log_line }
