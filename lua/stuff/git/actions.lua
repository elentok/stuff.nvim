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

local function cd_repo_root()
  local root = require("stuff.git.util").find_repo_root()
  if root ~= nil then
    if root == vim.fn.getcwd() then
      vim.notify("Already in\n" .. root)
    else
      vim.fn.chdir(root)
      vim.notify("Changed directory to\n " .. root)
    end
  end
end

return {
  fixup = fixup,
  stage_patch = stage_patch,
  cd_repo_root = cd_repo_root,
}
