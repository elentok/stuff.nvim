local escape = vim.fn.shellescape

local function find_pngpaste_script_path()
  local util = require("stuff.util")
  return util.get_lua_script_path() .. "/pngpaste-mac.sh"
end

---@return string|nil
local function find_wl_paste()
  local util = require("stuff.util")
  if util.has_command("wl-paste") then return "wl-paste" end

  if util.has_command("wl-clip.paste") then return "wl-clip.paste" end

  vim.notify(
    "wl-paste is missing, please install the 'wl-clipboard' package (or 'wl-clip' via snap)",
    vim.log.levels.ERROR
  )
  return nil
end

local function optimize_image(filepath)
  local util = require("stuff.util")
  if util.has_command("pngcrush") then
    util.run_shell("pngcrush -ow " .. escape(filepath))
  else
    vim.notify("pngcrush is missing, skipping optimization", vim.log.levels.WARN)
  end
end

---@param filepath string
---@return boolean
local function paste_image_to_file_in_linux(filepath)
  local util = require("stuff.util")
  if vim.env.XDG_SESSION_TYPE == "wayland" then
    local wlPaste = find_wl_paste()
    if wlPaste == nil then return false end
    return util.run_shell(wlPaste .. " -t image/png > " .. escape(filepath))
  end

  return util.run_shell("xclip -selection clipboard -t image/png -o > " .. escape(filepath))
end

---@param filepath string
---@return boolean
local function paste_image_to_file(filepath)
  local util = require("stuff.util")
  local sys = vim.uv.os_uname().sysname
  if sys == "Darwin" then
    return util.run_shell(find_pngpaste_script_path() .. " " .. escape(filepath))
  elseif sys == "Linux" then
    return paste_image_to_file_in_linux(filepath)
  else
    vim.notify("Currently only Mac and Linux are supported", vim.log.levels.ERROR)
    return false
  end
end

local function find_next_image_name()
  local util = require("stuff.util")
  local basename = vim.fn.expand("%:t:r")
  local index = 1
  local name = basename .. "01"
  while util.file_exists(util.prefix_with_buffer_dir(name .. ".png")) do
    index = index + 1
    name = string.format("%s%02d", basename, index)
  end
  return name
end

local function paste_image()
  local util = require("stuff.util")
  local ui = require("stuff.util.ui")
  vim.ui.input({
    prompt = "Enter image name:",
    default = find_next_image_name(),
  }, function(name)
    local filepath = util.prefix_with_buffer_dir(name .. ".png")
    if util.file_exists(filepath) and not ui.confirm("File already exists, overwrite?") then
      return
    end
    if not paste_image_to_file(filepath) then return end
    optimize_image(filepath)
    local link = string.format("![%s.png](%s.png)", name, name)
    vim.api.nvim_put({ link }, "c", true, true)
  end)
end

return paste_image
