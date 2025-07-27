---@return string The path to {file} relative to {dir}
---@param dir string
---@param filename string
local function relative_path(dir, filename)
  local up = ""
  local rel_path = nil
  while rel_path == nil do
    rel_path = vim.fs.relpath(dir, filename)
    if rel_path == nil then
      dir = vim.fn.fnamemodify(dir, ":h")
      up = up .. "../"
    end
  end

  return up .. rel_path
end

local function current_script_dir()
  local path = debug.getinfo(2, "S").source:sub(2)
  return vim.fs.dirname(path)
end

return { relative_path = relative_path, current_script_dir = current_script_dir }
