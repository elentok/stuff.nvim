local function put(...)
  local objects = {}
  for i = 1, select("#", ...) do
    local v = select(i, ...)
    table.insert(objects, vim.inspect(v))
  end

  print(table.concat(objects, " "))
  return ...
end

---@param target { [string]: any }
---@param src { [string]: any }
local function merge_config(target, src)
  for key, value in pairs(src) do
    if target[key] == nil then
      target[key] = value
    else
      if type(target[key]) == "table" then
        if vim.isarray(target[key]) then
          vim.list_extend(target[key], src[key])
        else
          merge_config(target[key], src[key])
        end
      else
        target[key] = value
      end
    end
  end
end

---@param filepath string
---@return boolean
local function file_exists(filepath)
  return vim.fn.filereadable(filepath) ~= 0
end

---@param cmd string
---@return boolean
local function has_command(cmd)
  return vim.fn.exepath(cmd) ~= ""
end

---@param cmd string
---@return boolean
local function run_shell(cmd)
  local output = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify(string.format("Command '%s' failed: %s", cmd, output), vim.log.levels.ERROR)
    return false
  end

  return true
end

---@return string
local function get_lua_script_path()
  local info = debug.getinfo(2, "S")
  local script_path = info.source:sub(2)
  local script_dir = vim.fn.fnamemodify(script_path, ":p:h")
  return script_dir
end

---@param path string
local function relative_to_buffer(path)
  return vim.fn.resolve(vim.fn.expand("%:p:h") .. "/" .. path)
end

---@param msg string
local function confirm(msg)
  return vim.fn.confirm(msg, "&Yes\n&No") == 1
end

return {
  put = put,
  merge_config = merge_config,
  file_exists = file_exists,
  has_command = has_command,
  run_shell = run_shell,
  get_lua_script_path = get_lua_script_path,
  relative_to_buffer = relative_to_buffer,
  confirm = confirm,
}
