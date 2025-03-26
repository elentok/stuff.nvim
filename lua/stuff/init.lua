---@class StuffOptions
---@field toggleWord? ToggleWordOptions

---@param opts? StuffOptions
local function setup(opts)
  if opts and opts.toggleWord then
    require("stuff.toggle-word.setup")(opts.toggleWord)
  end
end

return { setup = setup }
