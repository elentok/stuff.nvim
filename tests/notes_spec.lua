local daily = require("stuff.notes.daily")
local setup = require("stuff.notes.setup")
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

  describe("wrap in codeblock", function()
    local original_input
    local original_mapleader

    before_each(function()
      original_input = vim.ui.input
      original_mapleader = vim.g.mapleader
      vim.g.mapleader = " "
      setup()
    end)

    after_each(function()
      vim.ui.input = original_input
      vim.g.mapleader = original_mapleader
      pcall(vim.keymap.del, "n", "<leader>cb")
      pcall(vim.keymap.del, "x", "<leader>cb")
    end)

    it("wraps the current line in normal mode", function()
      local source_buf = vim.api.nvim_create_buf(false, true)
      local mapping = vim.fn.maparg("<leader>cb", "n", false, true)

      vim.api.nvim_set_current_buf(source_buf)
      vim.api.nvim_buf_set_lines(source_buf, 0, -1, false, { "hello", "world", "bla" })
      vim.api.nvim_win_set_cursor(0, { 2, 0 })

      vim.ui.input = function(_, on_confirm) on_confirm("ts") end

      mapping.callback()

      assert.same({
        "hello",
        "```ts",
        "world",
        "```",
        "bla",
      }, vim.api.nvim_buf_get_lines(source_buf, 0, -1, false))
    end)

    it("wraps a multiline visual selection", function()
      local source_buf = vim.api.nvim_create_buf(false, true)

      vim.api.nvim_set_current_buf(source_buf)
      vim.api.nvim_buf_set_lines(source_buf, 0, -1, false, { "hello", "world", "bla" })

      vim.ui.input = function(_, on_confirm) on_confirm("ts") end

      vim.cmd("normal! ggVjj")
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<leader>cb", true, false, true), "x", false)

      assert.same({
        "```ts",
        "hello",
        "world",
        "bla",
        "```",
      }, vim.api.nvim_buf_get_lines(source_buf, 0, -1, false))
    end)

    it("uses the original buffer after async input changes focus", function()
      local source_buf = vim.api.nvim_create_buf(false, true)
      local other_buf = vim.api.nvim_create_buf(false, true)

      vim.api.nvim_set_current_buf(source_buf)
      vim.api.nvim_buf_set_lines(source_buf, 0, -1, false, { "hello", "world", "bla" })

      vim.ui.input = function(_, on_confirm)
        vim.api.nvim_set_current_buf(other_buf)
        vim.api.nvim_buf_set_lines(other_buf, 0, -1, false, { "other" })
        on_confirm("ts")
      end

      vim.cmd("normal! ggVjj")
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<leader>cb", true, false, true), "x", false)

      assert.same({
        "```ts",
        "hello",
        "world",
        "bla",
        "```",
      }, vim.api.nvim_buf_get_lines(source_buf, 0, -1, false))
      assert.same({ "other" }, vim.api.nvim_buf_get_lines(other_buf, 0, -1, false))
    end)
  end)
end)
