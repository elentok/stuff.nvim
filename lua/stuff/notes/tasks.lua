local function toggle_done()
  local line = vim.api.nvim_get_current_line()

  -- If it's any non-done checkbox (e.g. [ ], [w], [o], [~], etc.)
  if line:match("^%s*%- %[[^xX]%]") then
    -- Change to done [x]
    line = line:gsub("^(%s*%- %[)[^%]](%])", "%1x%2")
  elseif line:match("^%s*%- %[[xX]%]") then
    -- Change from done [x] to unchecked [ ]
    line = line:gsub("^(%s*%- %[)[xX](%])", "%1 %2")
  else
    -- If no checkbox, add a new unchecked box
    line = "- [ ] " .. line
  end

  vim.api.nvim_set_current_line(line)
end

return {
  toggle_done = toggle_done,
}
