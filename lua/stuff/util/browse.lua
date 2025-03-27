---@param command string
---@param link string
local function exec(command, link)
  vim.fn.jobstart({ command, link }, {
    on_exit = function(_, exitcode, _)
      if exitcode == 0 then
        vim.notify("Link opened.")
      else
        vim.notify(
          'Error opening link with "' .. command .. " " .. link .. '"',
          vim.log.levels.ERROR
        )
      end
    end,
  })
end

---@param link string
local function browse(link)
  if vim.env.SSH_TTY ~= nil then
    vim.notify("Link copied to clipboard.")
    vim.fn.setreg("*", link)
    vim.fn.setreg("+", link)
  elseif vim.fn.has("wsl") == 1 then
    exec("explorer.exe", link)
  elseif vim.fn.has("macunix") == 1 then
    exec("open", link)
  else
    exec("xdg-open", link)
  end
end

return browse
