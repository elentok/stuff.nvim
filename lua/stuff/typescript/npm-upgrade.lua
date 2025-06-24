local ui = require("stuff.util.ui")

---@param line string
---@return string
local function extract_package_name(line)
  local package_name = line:match('"([^"]+)":')
  return package_name
end

---@class PackageInfo
---@field current string
---@field latest string

---@param package_name string
---@param callback fun(package_info: PackageInfo|nil)
local function get_package_info(package_name, callback)
  vim.notify(string.format("Checking latest version for %s...", package_name))

  vim.system({ "npm", "outdated", package_name, "--json" }, { text = true }, function(obj)
    if obj.code ~= 0 and obj.stdout == "" then
      vim.schedule(function()
        vim.notify(string.format("Package %s is up to date", package_name))
        callback(nil)
      end)
      return
    end

    local result = obj.stdout
    if result == "" then
      vim.schedule(function()
        vim.notify(string.format("No output from npm outdated command"), vim.log.levels.ERROR)
        callback(nil)
      end)
      return
    end

    local ok, data = pcall(vim.json.decode, result)
    if not ok then
      vim.schedule(function()
        vim.notify(string.format("Failed to parse JSON: %s", result), vim.log.levels.ERROR)
        callback(nil)
      end)
      return
    end

    if not data[package_name] then
      vim.schedule(function()
        vim.notify(string.format("Package %s is up to date", package_name))
        callback(nil)
      end)
      return
    end

    vim.schedule(function() callback(data[package_name]) end)
  end)
end

local function npm_upgrade()
  local line = vim.api.nvim_get_current_line()
  local package_name = extract_package_name(line)

  if not package_name then
    vim.notify("No package name found on current line", vim.log.levels.ERROR)
    return
  end

  get_package_info(package_name, function(package_info)
    if package_info == nil then return end

    local current = package_info.current
    local latest = package_info.latest

    if current == latest then
      vim.notify(string.format("Package %s is up to date", package_name))
      return
    end

    local msg = string.format("Upgrade %s to %s?", package_name, latest)
    if ui.confirm(msg) then
      local new_line = line:gsub(
        '"[^"]*"(%s*:%s*)"[^"]*"',
        function(colon_part) return string.format('"%s"%s"^%s"', package_name, colon_part, latest) end
      )

      local row = vim.api.nvim_win_get_cursor(0)[1]
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
      vim.notify(string.format("Upgraded %s to ^%s", package_name, latest))
    end
  end)
end

return { npm_upgrade = npm_upgrade, get_package_info = get_package_info }
