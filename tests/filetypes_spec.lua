local setup = require("stuff.filetypes")

describe("filetypes", function()
  it("sets yaml.docker-compose filetype for docker-compose.yml", function()
    setup()
    local file = vim.fn.tempname() .. "-docker-compose.yml"
    vim.fn.writefile({}, file)
    vim.cmd("edit " .. vim.fn.fnameescape(file))
    local ft = vim.bo.filetype
    vim.cmd("bdelete!")
    vim.fn.delete(file)
    assert.equals("yaml.docker-compose", ft)
  end)

  it("sets markdown filetype for .mdc files", function()
    setup()
    local file = vim.fn.tempname() .. ".mdc"
    vim.fn.writefile({}, file)
    vim.cmd("edit " .. vim.fn.fnameescape(file))
    local ft = vim.bo.filetype
    vim.cmd("bdelete!")
    vim.fn.delete(file)
    assert.equals("markdown", ft)
  end)

  it("applies extra_mappings", function()
    setup({ ["*.stufftest"] = "json" })
    local file = vim.fn.tempname() .. ".stufftest"
    vim.fn.writefile({}, file)
    vim.cmd("edit " .. vim.fn.fnameescape(file))
    local ft = vim.bo.filetype
    vim.cmd("bdelete!")
    vim.fn.delete(file)
    assert.equals("json", ft)
  end)
end)
