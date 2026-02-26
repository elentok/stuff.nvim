local pattern_to_filetype = {
  ["*docker-compose.yml"] = "yaml.docker-compose",
  ["*.mdc"] = "markdown",
  ["Jenkinsfile*"] = "groovy",
}

---@param extra_mappings { [string]: string } | nil
local function setup(extra_mappings)
  pattern_to_filetype = vim.tbl_extend("force", pattern_to_filetype, extra_mappings or {})

  for pattern, filetype in pairs(pattern_to_filetype) do
    if filetype ~= nil then
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = pattern,
        callback = function() vim.bo.filetype = filetype end,
      })
    end
  end
end

return setup
