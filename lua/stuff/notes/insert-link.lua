---@param filename string
---@return string
local function get_markdown_title(filename)
  ---@type string[]
  local lines = vim.fn.readfile(filename, "", 50)
  if #lines == 0 then
    vim.notify("File " .. filename .. "is empty")
    return vim.fs.basename(filename)
  end

  for _, line in ipairs(lines) do
    local match, exitcode = line:gsub("^# *", "")
    if exitcode ~= 0 then return match end
  end

  return vim.fs.basename(filename)
end

---@param target_filename string
local function insert_link_to_file(target_filename)
  local buf_file = vim.api.nvim_buf_get_name(0)
  local buf_dir = vim.fn.fnamemodify(buf_file, ":h")
  local rel_path = require("stuff.util.path").relative_path(buf_dir, target_filename)

  local title = get_markdown_title(target_filename)

  put(string.format("[%s](%s)", title, rel_path))
end

local function insert_link()
  Snacks.picker.files({
    confirm = function(picker, item)
      local target_filename = item.cwd .. "/" .. item.file

      picker:close()
      vim.defer_fn(function() insert_link_to_file(target_filename) end, 1)
    end,
    ft = "md",
  })
end

return {
  insert_link = insert_link,
}
