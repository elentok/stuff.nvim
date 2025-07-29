---@param cmd string[]
local function in_new_tab(cmd)
  local shell = require("stuff.util.shell")
  -- "--hold=yes",
  local args = vim.list_extend({ "@launch", "--type=tab", "--copy-env" }, cmd)

  shell("kitten", { args = args })
end

return {
  in_new_tab = in_new_tab,
}
