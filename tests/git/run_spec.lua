local run = require("stuff.git.run")

local function make_repo()
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")

  vim.system({ "git", "init" }, { cwd = dir }):wait()
  vim.system({ "git", "remote", "add", "origin", "git@github.com:test/repo.git" }, { cwd = dir }):wait()

  local file = dir .. "/file.lua"
  vim.fn.writefile({ "return 1" }, file)
  vim.system({ "git", "add", "." }, { cwd = dir }):wait()
  vim.system({ "git", "commit", "-m", "init", "--no-gpg-sign" }, { cwd = dir }):wait()

  local function cleanup() vim.fn.delete(dir, "rf") end

  return { dir = dir, file = file, cleanup = cleanup }
end

describe("git.run", function()
  describe("silently", function()
    it("returns trimmed stdout on success", function()
      local repo = make_repo()
      vim.cmd("edit " .. vim.fn.fnameescape(repo.file))

      local result = run.silently({ "rev-parse", "--show-toplevel" })
      vim.cmd("bdelete!")

      assert.is_truthy(result)
      assert.equals(vim.uv.fs_realpath(repo.dir), vim.uv.fs_realpath(result))
      repo.cleanup()
    end)

    it("returns nil on failure", function()
      local repo = make_repo()
      vim.cmd("edit " .. vim.fn.fnameescape(repo.file))

      local result = run.silently({ "log", "--oneline", "nonexistent-ref" })
      vim.cmd("bdelete!")

      assert.is_nil(result)
      repo.cleanup()
    end)

    it("can read config values", function()
      local repo = make_repo()
      vim.cmd("edit " .. vim.fn.fnameescape(repo.file))

      local result = run.silently({ "config", "--get", "remote.origin.url" })
      vim.cmd("bdelete!")

      assert.equals("git@github.com:test/repo.git", result)
      repo.cleanup()
    end)
  end)
end)
