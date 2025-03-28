---@param filepath? string
---@return string|nil
local function find_git_root(filepath)
  if filepath == nil then
    if vim.bo.filetype == "oil" then
      filepath = require("oil").get_current_dir()
    else
      filepath = vim.fn.expand("%")
    end
  end

  if filepath == nil then
    return nil
  end

  local path = vim.uv.fs_realpath(filepath)

  while path ~= "/" do
    if vim.uv.fs_stat(path .. "/.git") then
      return path
    end
    path = vim.uv.fs_realpath(path .. "/..")
  end
  return nil
end

-- When the current buffer is outside the current workdir it returns the git root for that buffer,
-- Otherwise, returns nil.
---@return string|nil
local function find_repo_root()
  local buffer = require("stuff.util.buffer")
  if buffer.is_unsaved() then -- or buffer.is_in_cwd() then
    return nil
  end

  return find_git_root()
end

return find_repo_root
