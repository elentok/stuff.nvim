-- Set up a fake clipboard provider before any tests run.
-- This ensures tests pass in headless/CI environments without xclip/xsel.
local store = {}
vim.g.clipboard = {
  name = "fake",
  copy = {
    ["+"] = function(lines) store["+"] = table.concat(lines, "\n") end,
    ["*"] = function(lines) store["*"] = table.concat(lines, "\n") end,
  },
  paste = {
    ["+"] = function() return vim.split(store["+"] or "", "\n") end,
    ["*"] = function() return vim.split(store["*"] or "", "\n") end,
  },
}

describe("yank", function()
  describe("yank to register", function()
    it("copies text to the + register", function()
      local yank = require("stuff.yank")
      yank.yank("hello world", { quiet = true })
      assert.equals("hello world", vim.fn.getreg("+"))
    end)

    it("copies multiline text", function()
      local yank = require("stuff.yank")
      local text = "line1\nline2\nline3"
      yank.yank(text, { quiet = true })
      assert.equals(text, vim.fn.getreg("+"))
    end)
  end)
end)
