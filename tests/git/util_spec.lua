local git_util = require("stuff.git.util")

--- Create a temporary git repo with a remote and a committed file.
local function make_repo(opts)
  opts = opts or {}
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")

  vim.system({ "git", "init" }, { cwd = dir }):wait()
  vim
    .system({ "git", "remote", "add", "origin", "git@github.com:test/repo.git" }, { cwd = dir })
    :wait()

  if opts.extra_remote then
    vim
      .system(
        { "git", "remote", "add", opts.extra_remote, "git@github.com:test/upstream.git" },
        { cwd = dir }
      )
      :wait()
  end

  local file = dir .. "/file.lua"
  vim.fn.writefile({ "return 1" }, file)
  vim.system({ "git", "add", "." }, { cwd = dir }):wait()
  vim.system({ "git", "commit", "-m", "init", "--no-gpg-sign" }, { cwd = dir }):wait()

  local function cleanup() vim.fn.delete(dir, "rf") end

  return { dir = dir, file = file, cleanup = cleanup }
end

describe("git.util", function()
  describe("get_config", function()
    it("reads a git config value", function()
      local repo = make_repo()
      vim.cmd("edit " .. vim.fn.fnameescape(repo.file))

      local result = git_util.get_config("remote.origin.url")
      vim.cmd("bdelete!")

      assert.equals("git@github.com:test/repo.git", result)
      repo.cleanup()
    end)

    it("returns nil for missing config keys", function()
      local repo = make_repo()
      vim.cmd("edit " .. vim.fn.fnameescape(repo.file))

      stub(vim, "notify")
      local result = git_util.get_config("nonexistent.key")
      vim.notify:revert()
      vim.cmd("bdelete!")

      assert.is_nil(result)
      repo.cleanup()
    end)
  end)

  describe("toplevel", function()
    it("returns the repo root directory", function()
      local repo = make_repo()
      vim.cmd("edit " .. vim.fn.fnameescape(repo.file))

      local result = git_util.toplevel()
      vim.cmd("bdelete!")

      -- resolve symlinks for comparison (e.g. /tmp vs /private/tmp on macOS)
      assert.equals(vim.uv.fs_realpath(repo.dir), vim.uv.fs_realpath(result))
      repo.cleanup()
    end)
  end)

  describe("remotes", function()
    it("lists configured remotes", function()
      local repo = make_repo({ extra_remote = "upstream" })
      vim.cmd("edit " .. vim.fn.fnameescape(repo.file))

      local result = git_util.remotes()
      vim.cmd("bdelete!")

      assert.is_true(vim.tbl_contains(result, "origin"))
      assert.is_true(vim.tbl_contains(result, "upstream"))
      repo.cleanup()
    end)

    it("returns only origin when no extra remotes", function()
      local repo = make_repo()
      vim.cmd("edit " .. vim.fn.fnameescape(repo.file))

      local result = git_util.remotes()
      vim.cmd("bdelete!")

      assert.is_true(vim.tbl_contains(result, "origin"))
      repo.cleanup()
    end)
  end)

  describe("find_repo_root", function()
    it("returns the repo root for a regular git repo", function()
      local repo = make_repo()
      vim.cmd("edit " .. vim.fn.fnameescape(repo.file))

      local result = git_util.find_repo_root()
      vim.cmd("bdelete!")

      assert.equals(vim.uv.fs_realpath(repo.dir), vim.uv.fs_realpath(result))
      repo.cleanup()
    end)

    it("returns the worktree root (not the bare repo) for a git worktree", function()
      local repo = make_repo()
      local wt_dir = vim.fn.tempname()
      vim.system({ "git", "worktree", "add", wt_dir, "-b", "test-worktree" }, { cwd = repo.dir }):wait()

      local wt_file = wt_dir .. "/file.lua"
      vim.cmd("edit " .. vim.fn.fnameescape(wt_file))

      local result = git_util.find_repo_root()
      vim.cmd("bdelete!")

      assert.equals(vim.uv.fs_realpath(wt_dir), vim.uv.fs_realpath(result))
      assert.not_equals(vim.uv.fs_realpath(repo.dir), vim.uv.fs_realpath(result))

      vim.fn.delete(wt_dir, "rf")
      repo.cleanup()
    end)

    it("returns nil when not in a git repo", function()
      local dir = vim.fn.tempname()
      vim.fn.mkdir(dir, "p")
      local file = dir .. "/file.lua"
      vim.fn.writefile({ "return 1" }, file)
      vim.cmd("edit " .. vim.fn.fnameescape(file))

      local result = git_util.find_repo_root()
      vim.cmd("bdelete!")

      assert.is_nil(result)
      vim.fn.delete(dir, "rf")
    end)
  end)
end)
