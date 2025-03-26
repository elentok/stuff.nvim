local config = require("stuff.toggle-word.config")

local function log(message)
  if config.debug then
    print("[stuff.toggle-word] " .. message)
  end
end

local function toggle_word()
  local value = vim.fn.expand("<cword>")
  log("Toggle world from [" .. value .. "]")
  local other_value = config.values[value]
  if other_value ~= nil then
    log("Toggle world to [" .. other_value .. "]")
    vim.cmd('normal! "' .. config.register .. "ciw" .. other_value)
  else
    log("Did not find an opposite value for '" .. value .. "'")
  end
end

return { toggle_word = toggle_word }
