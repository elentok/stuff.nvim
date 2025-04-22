---@class UrlOpts
---@field branch? string
---@field remote? string
---@field include_line? boolean

---@param remote? string
local function repo_url(remote)
  remote = remote or "origin"
  local git = require("stuff.git.util")

  local url = git.get_config("remote." .. remote .. ".url")
  if url == nil then
    return
  end

  return url
    :gsub("git@([^:]+):", "https://%1/")
    :gsub("github.com-[^/]*", "github.com")
    :gsub(".git$", "")
end

---@param filepath? string
---@return string|nil
local function repo_filepath(filepath)
  filepath = filepath or vim.fn.expand("%")
  local git = require("stuff.git.util")
  local root = git.toplevel()
  if root == nil then
    return nil
  end

  return vim.fn.substitute(filepath, root, "", "")
end

---@param opts? UrlOpts
local function get_url(opts)
  opts = opts or {}
  local branch = opts.branch or "main"

  local remote = opts.remote
  if remote == nil then
    local remotes = require("stuff.git.util").remotes()
    if vim.tbl_contains(remotes, "upstream") then
      remote = "upstream"
    elseif vim.tbl_contains(remotes, "origin") then
      remote = "origin"
    else
      remote = remotes[1]
    end
  end

  local repo = repo_url(remote)
  local filepath = repo_filepath()

  local line_suffix = ""
  if opts.include_line ~= false then
    line_suffix = "#L" .. vim.fn.line(".")
  end

  return repo .. "/blob/" .. branch .. filepath .. line_suffix
end

---@param opts? UrlOpts
local function open(opts)
  local browse = require("stuff.util.browse")
  browse(get_url(opts))
end

---@param opts? UrlOpts
local function yank(opts)
  local url = get_url(opts)
  vim.fn.setreg("+", url)
  Snacks.notifier.notify("Copied " .. url)
end

return {
  get_url = get_url,
  open = open,
  yank = yank,
}
