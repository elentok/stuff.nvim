local function reset_changes()
  local ui = require("stuff.util.ui")
  if ui.confirm("Reset changes in current file?") then
    vim.cmd("silent edit!")
    vim.fn.system("git checkout -- " .. vim.fn.shellescape(vim.fn.expand("%:p")))
    vim.cmd("silent edit")
  end
end

local function add_with_patch()
  local run = require("stuff.git.run")
  run.in_terminal({ "add", "-p", vim.fn.expand("%:p") })
end

local function checkout_with_patch()
  local run = require("stuff.git.run")
  run.in_terminal({ "checkout", "-p", vim.fn.expand("%:p") })
end

local function write_and_stage()
  vim.cmd("write")
  vim.system({ "git", "add", vim.fn.expand("%:p") }):wait()
  print("Staged file")
end

return {
  reset_changes = reset_changes,
  add_with_patch = add_with_patch,
  checkout_with_patch = checkout_with_patch,
  write_and_stage = write_and_stage,
}
