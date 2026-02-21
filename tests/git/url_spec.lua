local url = require("stuff.git.url")
local shell = require("stuff.util.shell")

--- Create a temporary git repo with a remote and a committed file.
--- Returns { dir, file, cleanup }
local function make_repo(opts)
  opts = opts or {}
  local remote_url = opts.remote_url or "git@github.com:testuser/testrepo.git"

  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")

  vim.system({ "git", "init" }, { cwd = dir }):wait()
  vim.system({ "git", "remote", "add", "origin", remote_url }, { cwd = dir }):wait()

  -- Create and commit a file so HEAD exists
  local file = dir .. "/hello.lua"
  vim.fn.writefile({ "return 1" }, file)
  vim.system({ "git", "add", "." }, { cwd = dir }):wait()
  vim.system({ "git", "commit", "-m", "init", "--no-gpg-sign" }, { cwd = dir }):wait()

  local function cleanup() vim.fn.delete(dir, "rf") end

  return { dir = dir, file = file, cleanup = cleanup }
end

describe("git.url", function()
  describe("normalize_remote_url", function()
    it(
      "converts SSH URLs to HTTPS",
      function()
        assert.equals(
          "https://github.com/elentok/stuff.nvim",
          url.normalize_remote_url("git@github.com:elentok/stuff.nvim.git")
        )
      end
    )

    it(
      "handles SSH URLs without .git suffix",
      function()
        assert.equals(
          "https://github.com/elentok/stuff.nvim",
          url.normalize_remote_url("git@github.com:elentok/stuff.nvim")
        )
      end
    )

    it(
      "strips .git from HTTPS URLs",
      function()
        assert.equals(
          "https://github.com/elentok/stuff.nvim",
          url.normalize_remote_url("https://github.com/elentok/stuff.nvim.git")
        )
      end
    )

    it(
      "normalizes SSH aliases (github.com-personal)",
      function()
        assert.equals(
          "https://github.com/elentok/stuff.nvim",
          url.normalize_remote_url("git@github.com-personal:elentok/stuff.nvim.git")
        )
      end
    )

    it(
      "leaves clean HTTPS URLs unchanged",
      function()
        assert.equals(
          "https://github.com/elentok/stuff.nvim",
          url.normalize_remote_url("https://github.com/elentok/stuff.nvim")
        )
      end
    )
  end)

  describe("repo_url", function()
    it("returns normalized HTTPS URL from a real git remote", function()
      local repo = make_repo({ remote_url = "git@github.com:testuser/testrepo.git" })

      -- Open the file so git commands resolve to our dummy repo
      vim.cmd("edit " .. vim.fn.fnameescape(repo.file))
      local result = url.repo_url("origin")
      vim.cmd("bdelete!")

      assert.equals("https://github.com/testuser/testrepo", result)
      repo.cleanup()
    end)

    it("returns nil when remote does not exist", function()
      local repo = make_repo()

      vim.cmd("edit " .. vim.fn.fnameescape(repo.file))
      stub(vim, "notify")
      local result = url.repo_url("nonexistent")
      vim.notify:revert()
      vim.cmd("bdelete!")

      assert.is_nil(result)
      repo.cleanup()
    end)
  end)

  describe("repo_filepath", function()
    it("returns path relative to repo root", function()
      local repo = make_repo()
      -- Use realpath so it matches what git reports as toplevel
      local realfile = vim.uv.fs_realpath(repo.file)

      vim.cmd("edit " .. vim.fn.fnameescape(repo.file))
      local result = url.repo_filepath(realfile)
      vim.cmd("bdelete!")

      assert.equals("/hello.lua", result)
      repo.cleanup()
    end)
  end)
end)
