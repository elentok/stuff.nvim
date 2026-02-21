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

  -- Start from the directory, not the file itself, because
  -- fs_realpath("file.lua/..") fails on Linux (file is not a directory).
  local path = vim.uv.fs_realpath(vim.fs.dirname(filepath))
  if path == nil then
    return nil
  end

  while path and path ~= "/" do
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
