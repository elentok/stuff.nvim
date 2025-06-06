---@param commit_hash string
---@param commit_title string?
local function fixup(commit_hash, commit_title)
  if commit_hash == nil then return end

  local ui = require("stuff.util.ui")
  local run = require("stuff.git.run")

  local title = commit_title or commit_hash

  if ui.confirm("Fixup " .. title .. "?") then
    run.silently({ "commit", "--fixup", commit_hash })
  end
end

---@param file string
local function stage_patch(file)
  local run = require("stuff.git.run")
  run.in_terminal({ "add", "-p", file })
end

return {
  fixup = fixup,
  stage_patch = stage_patch,
}
