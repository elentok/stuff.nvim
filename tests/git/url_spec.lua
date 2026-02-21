local url = require("stuff.git.url")

describe("git.url", function()
  describe("normalize_remote_url", function()
    it("converts SSH URLs to HTTPS", function()
      assert.equals(
        "https://github.com/elentok/stuff.nvim",
        url.normalize_remote_url("git@github.com:elentok/stuff.nvim.git")
      )
    end)

    it("handles SSH URLs without .git suffix", function()
      assert.equals(
        "https://github.com/elentok/stuff.nvim",
        url.normalize_remote_url("git@github.com:elentok/stuff.nvim")
      )
    end)

    it("strips .git from HTTPS URLs", function()
      assert.equals(
        "https://github.com/elentok/stuff.nvim",
        url.normalize_remote_url("https://github.com/elentok/stuff.nvim.git")
      )
    end)

    it("normalizes SSH aliases (github.com-personal)", function()
      assert.equals(
        "https://github.com/elentok/stuff.nvim",
        url.normalize_remote_url("git@github.com-personal:elentok/stuff.nvim.git")
      )
    end)

    it("leaves clean HTTPS URLs unchanged", function()
      assert.equals(
        "https://github.com/elentok/stuff.nvim",
        url.normalize_remote_url("https://github.com/elentok/stuff.nvim")
      )
    end)
  end)
end)
