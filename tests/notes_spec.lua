local daily = require("stuff.notes.daily")
local weekly = require("stuff.notes.weekly")

describe("notes", function()
  describe("get_daily_note_filename", function()
    it("returns path with year/month structure", function()
      local tmpdir = vim.fn.tempname()
      vim.fn.mkdir(tmpdir, "p")

      local date = os.date("%Y-%m-%d")
      local year = os.date("%Y")
      local month = os.date("%m")
      local expected = string.format("%s/daily/%s/%s/%s.md", tmpdir, year, month, date)

      local result = daily.get_daily_note_filename(tmpdir)
      assert.equals(expected, result)

      -- Verify the file was created with a date header
      local lines = vim.fn.readfile(result)
      assert.is_true(#lines > 0)
      assert.is_true(vim.startswith(lines[1], "# "))

      vim.fn.delete(tmpdir, "rf")
    end)

    it("returns same file on repeated calls", function()
      local tmpdir = vim.fn.tempname()
      vim.fn.mkdir(tmpdir, "p")

      local first = daily.get_daily_note_filename(tmpdir)
      local second = daily.get_daily_note_filename(tmpdir)
      assert.equals(first, second)

      vim.fn.delete(tmpdir, "rf")
    end)
  end)

  describe("get_weekly_note_filename", function()
    it("returns path with weekly/year structure", function()
      local tmpdir = vim.fn.tempname()
      vim.fn.mkdir(tmpdir, "p")

      local result = weekly.get_weekly_note_filename(tmpdir)

      -- Should be under weekly/{year}/
      assert.is_truthy(result:match("/weekly/%d%d%d%d/"))
      -- Should end with .md
      assert.is_truthy(result:match("%.md$"))
      -- Should contain "week"
      assert.is_truthy(result:match("week"))

      -- Verify the file was created with a week header
      local lines = vim.fn.readfile(result)
      assert.is_true(#lines > 0)
      assert.is_true(vim.startswith(lines[1], "# Week "))

      vim.fn.delete(tmpdir, "rf")
    end)
  end)
end)
