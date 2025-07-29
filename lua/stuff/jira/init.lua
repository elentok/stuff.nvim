local workitem_re = vim.regex("[A-Za-z]\\+-[0-9]\\+")

local function preview()
  local workitem = require("stuff.util").find_closest_match(workitem_re)
  if workitem ~= nil then
    -- vim.notify("Found work item '" .. workitem)
    Snacks.terminal("jira issue view --comments 100 " .. workitem, { win = { border = "rounded" } })
  else
    vim.notify("🤷‍♂️ Work item not found", "warn")
  end
end

local function open()
  local workitem = require("stuff.util").find_closest_match(workitem_re)
  if workitem ~= nil then
    local run = require("stuff.util.run")
    run.in_new_tab({ "jira", "issue", "list", "-q", "key = " .. workitem })
  else
    vim.notify("🤷‍♂️ Work item not found", "warn")
  end
end

return { preview = preview, open = open }
