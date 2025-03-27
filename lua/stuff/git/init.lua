local function reset_file_changes()
  local ui = require("stuff.util.ui")
  if ui.confirm("Reset changes in current file?") then
    vim.cmd("silent edit!")
    vim.fn.system("git checkout -- " .. vim.fn.shellescape(vim.fn.expand("%")))
    vim.cmd("silent edit")
  end
end

local function add_file_patch()
  local git = require("stuff.util.git")
  git.run({ "add", "-p", vim.fn.expand("%") })
end

local function checkout_file_patch()
  local git = require("stuff.util.git")
  git.run({ "checkout", "-p", vim.fn.expand("%") })
end

local function write_and_add_file()
  vim.cmd("write")
  vim.system({ "git", "add", vim.fn.expand("%") }):wait()
  print("Staged file")
end

return {
  reset_file_changes = reset_file_changes,
  add_file_patch = add_file_patch,
  checkout_file_patch = checkout_file_patch,
  write_and_add_file = write_and_add_file,
}
