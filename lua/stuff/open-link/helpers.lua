--- If the link is a path relative to the current file that exists,
--- it will return the full path (prefixed with "file://")
---@param link string
local function find_abs_path(link)
  local path = vim.fn.resolve(vim.fn.expand("%:p:h") .. "/" .. link)
  if vim.fn.filereadable(path) then
    return "file://" .. path
  end
end

local function is_http_or_file_link(link)
  return vim.startswith(link, "http://")
    or vim.startswith(link, "https://")
    or vim.startswith(link, "file://")
    or vim.startswith(link, "/")
end

return {
  find_abs_path = find_abs_path,
  is_http_or_file_link = is_http_or_file_link,
}
