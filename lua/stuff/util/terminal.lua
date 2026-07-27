--- Terminal-agnostic helpers that dispatch to the current terminal backend.

---@param command string[]
local function new_tab(command)
  if require("stuff.util.herdr").is_inside_herdr() then
    require("stuff.util.herdr").new_tab(command)
    return
  end

  if require("stuff.util.kitty").is_inside_kitty() then
    require("stuff.util.kitty").new_tab(command)
    return
  end

  Snacks.terminal(command)
end

return {
  new_tab = new_tab,
}
