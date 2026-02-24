---@alias RelatedFileType RelatedFileType

local style_extensions = { css = true, scss = true, sass = true, less = true }
local index_names = { init = true, index = true, __init__ = true }
local structural_dirs = {
  src = true,
  lib = true,
  lua = true,
  tests = true,
  test = true,
  spec = true,
  __tests__ = true,
  app = true,
}

--- Extract the core name from a filename, stripping test/style affixes.
--- Examples:
---   MyComponent.test.tsx -> MyComponent
---   MyComponent.module.css -> MyComponent
---   test_utils.py -> utils
---   file_test.go -> file
---   related-files/init.lua -> related-files
---   Button/index.tsx -> Button
---   mypackage/__init__.py -> mypackage
---   related-files_spec.lua -> related-files
---@param filepath string
---@return string core_name
local function get_core_name(filepath)
  local basename = vim.fs.basename(filepath)

  -- Strip all extensions to get the stem, but handle multi-part extensions
  -- e.g. "MyComponent.test.tsx" -> parts = {"MyComponent", "test", "tsx"}
  local parts = vim.split(basename, ".", { plain = true })
  local stem = parts[1]

  -- For index/init files, use the parent directory name
  if index_names[stem] then
    local parent = vim.fs.basename(vim.fs.dirname(filepath))
    return parent
  end

  -- Strip test_ prefix (Python convention)
  if vim.startswith(stem, "test_") then stem = stem:sub(6) end

  -- Strip _test suffix (Go/Python convention)
  if stem:sub(-5) == "_test" then stem = stem:sub(1, -6) end

  -- Strip _spec suffix (busted/Ruby convention)
  if stem:sub(-5) == "_spec" then stem = stem:sub(1, -6) end

  return stem
end

--- Get a qualifying directory segment to disambiguate files with the same core name.
--- Walks upward from the file's parent, skipping dirs that match core_name and structural dirs.
---@param filepath string
---@param core_name string
---@param root string
---@return string qualifier
local function get_qualifier(filepath, core_name, root)
  local dir = vim.fs.dirname(filepath)
  while dir and #dir >= #root do
    local name = vim.fs.basename(dir)
    if dir == root then break end
    if name == core_name then
      -- skip directory matching core name (e.g. util/ for util/init.lua)
    elseif structural_dirs[name] then
      -- skip known structural dirs
    elseif vim.fs.basename(vim.fs.dirname(dir)) == "lua" then
      -- skip lua package name dirs (e.g. lua/stuff/ -> stuff is structural)
    else
      return name
    end
    dir = vim.fs.dirname(dir)
  end
  return ""
end

---@param filepath string
---@return RelatedFileType
local function classify_file(filepath)
  local basename = vim.fs.basename(filepath)
  local parts = vim.split(basename, ".", { plain = true })
  local stem = parts[1]
  local ext = parts[#parts]

  -- Check for test patterns
  if vim.startswith(stem, "test_") or stem:sub(-5) == "_test" or stem:sub(-5) == "_spec" then
    return "test"
  end
  for i = 2, #parts - 1 do
    if parts[i] == "test" or parts[i] == "spec" then return "test" end
  end

  -- Check for style patterns
  if style_extensions[ext] then return "style" end

  return "code"
end

---@class RelatedFile
---@field path string
---@field type RelatedFileType
---@field filename string

--- Run fd and return a list of absolute file paths.
---@param args string[]
---@return string[]
local function run_fd(args)
  local result = vim.fn.systemlist(args)
  if vim.v.shell_error ~= 0 then return {} end
  return result
end

--- Find all files related to the current buffer.
---@return RelatedFile[]
local function find_related_files()
  -- Return cached results if available
  if vim.b.related_files then return vim.b.related_files end

  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file == "" then return {} end

  local core_name = get_core_name(current_file)
  local root = vim.fs.root(0, ".git") or vim.fn.getcwd()
  local qualifier = get_qualifier(current_file, core_name, root)

  -- Search for files matching the core name using fd (faster, respects .gitignore)
  local candidates = run_fd({ "fd", "--type", "f", "--absolute-path", "-g", core_name .. "*", root })

  -- Also search for index files inside directories matching the core name
  for _, idx_name in ipairs({ "init", "index", "__init__" }) do
    local extra = run_fd({ "fd", "--type", "f", "--absolute-path", "--full-path", "/" .. core_name .. "/" .. idx_name .. "\\.", root })
    vim.list_extend(candidates, extra)
  end

  local results = {}
  for _, filepath in ipairs(candidates) do
    -- Skip current file and directories
    if filepath ~= current_file and vim.fn.isdirectory(filepath) == 0 then
      local candidate_core = get_core_name(filepath)
      if candidate_core == core_name and get_qualifier(filepath, core_name, root) == qualifier then
        table.insert(results, {
          path = filepath,
          type = classify_file(filepath),
          filename = vim.fs.basename(filepath),
        })
      end
    end
  end

  -- Cache on buffer
  vim.b.related_files = results
  return results
end

---@param type_filter RelatedFileType|nil
local function jump_to_related(type_filter)
  local files = find_related_files()

  if type_filter then
    files = vim.tbl_filter(function(f) return f.type == type_filter end, files)
  end

  if #files == 0 then
    if type_filter then
      vim.notify("Related " .. type_filter .. " file not found", vim.log.levels.WARN)
    else
      vim.notify("No related files found", vim.log.levels.WARN)
    end
    return
  end

  if #files == 1 then
    vim.cmd("edit " .. vim.fn.fnameescape(files[1].path))
    return
  end

  Snacks.picker({
    title = "Related Files",
    items = vim.tbl_map(
      function(f) return { text = f.filename, file = f.path, label = f.type } end,
      files
    ),
    format = function(item, _ctx)
      local ret = {}
      local type_hl = { test = "DiagnosticInfo", style = "DiagnosticHint", code = "DiagnosticOk" }
      table.insert(ret, { " " .. item.label .. " ", type_hl[item.label] or "Comment" })
      table.insert(ret, { " " .. item.text })
      return ret
    end,
    confirm = function(picker, item)
      picker:close()
      vim.cmd("edit " .. vim.fn.fnameescape(item.file))
    end,
  })
end

return {
  jump_to_related = jump_to_related,
  find_related_files = find_related_files,
  get_core_name = get_core_name,
  get_qualifier = get_qualifier,
  classify_file = classify_file,
}
