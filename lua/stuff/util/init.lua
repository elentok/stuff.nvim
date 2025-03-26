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
local function mergeConfig(target, src)
  for key, value in pairs(src) do
    if target[key] == nil then
      target[key] = value
    else
      if type(target[key]) == "table" then
        if vim.isarray(target[key]) then
          vim.list_extend(target[key], src[key])
        else
          mergeConfig(target[key], src[key])
        end
      else
        target[key] = value
      end
    end
  end
end

return { put = put, mergeConfig = mergeConfig }
