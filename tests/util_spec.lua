local util = require("stuff.util")
local path = require("stuff.util.path")

describe("util", function()
  describe("merge_config", function()
    it("merges flat values", function()
      local target = { a = 1, b = 2 }
      util.merge_config(target, { c = 3 })
      assert.equals(1, target.a)
      assert.equals(2, target.b)
      assert.equals(3, target.c)
    end)

    it("does not overwrite existing keys", function()
      local target = { a = 1 }
      util.merge_config(target, { a = 99 })
      assert.equals(99, target.a)
    end)

    it("extends arrays", function()
      local target = { items = { "a", "b" } }
      util.merge_config(target, { items = { "c" } })
      assert.same({ "a", "b", "c" }, target.items)
    end)

    it("recursively merges nested tables", function()
      local target = { nested = { x = 1 } }
      util.merge_config(target, { nested = { y = 2 } })
      assert.equals(1, target.nested.x)
      assert.equals(2, target.nested.y)
    end)

    it("handles nil src gracefully", function()
      local target = { a = 1 }
      util.merge_config(target, nil)
      assert.equals(1, target.a)
    end)

    it("adds new nested keys", function()
      local target = {}
      util.merge_config(target, { new_key = { deep = true } })
      assert.same({ deep = true }, target.new_key)
    end)
  end)

  describe("path.relative_path", function()
    it("returns relative path within same tree", function()
      assert.equals("bar/baz.lua", path.relative_path("/foo", "/foo/bar/baz.lua"))
    end)

    it("returns path with ../ when in different branches", function()
      local result = path.relative_path("/foo/bar", "/foo/qux/file.lua")
      assert.equals("../qux/file.lua", result)
    end)

    it("handles deeply nested paths", function()
      assert.equals("c/d.lua", path.relative_path("/a/b", "/a/b/c/d.lua"))
    end)
  end)
end)
