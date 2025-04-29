---@class StuffOptions
---@field toggle_word? ToggleWordOptions
---@field open_link? OpenLinkOptions
---@field paste_image? boolean
---@field git? boolean
---@field notes? boolean
---@field hebrew? boolean
---@field alternate_file? boolean
---@field scriptify? ScriptifyOptions
---@field log_line? LogLineOptions

---@param opts? StuffOptions
local function setup(opts)
  if not opts then
    return
  end

  if opts.toggle_word then
    require("stuff.toggle-word.setup")(opts.toggle_word)
  end

  if opts.open_link then
    require("stuff.open-link.setup")(opts.open_link)
  end

  if opts.paste_image then
    require("stuff.paste-image.setup")()
  end

  if opts.git then
    require("stuff.git.setup")()
  end

  if opts.notes then
    require("stuff.notes.setup")()
  end

  if opts.alternate_file then
    require("stuff.alternate-file.setup")()
  end

  if opts.scriptify then
    require("stuff.scriptify.setup")(opts.scriptify)
  end

  if opts.log_line then
    require("stuff.log-line.setup")(opts.log_line)
  end

  if opts.hebrew then
    require("stuff.hebrew-line.setup")()
  end
end

return { setup = setup }
