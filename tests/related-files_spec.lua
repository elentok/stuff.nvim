local related = require("stuff.related-files")

describe("related-files", function()
  describe("get_core_name", function()
    it("returns stem for plain files", function()
      assert.equals("MyComponent", related.get_core_name("src/MyComponent.tsx"))
      assert.equals("utils", related.get_core_name("lib/utils.ts"))
      assert.equals("main", related.get_core_name("main.go"))
    end)

    it("strips .test middle part", function()
      assert.equals("MyComponent", related.get_core_name("src/MyComponent.test.tsx"))
      assert.equals("utils", related.get_core_name("tests/utils.test.ts"))
    end)

    it(
      "strips .spec middle part",
      function() assert.equals("MyComponent", related.get_core_name("src/MyComponent.spec.tsx")) end
    )

    it("strips .module middle part", function()
      assert.equals("MyComponent", related.get_core_name("styles/MyComponent.module.css"))
      assert.equals("MyComponent", related.get_core_name("MyComponent.module.scss"))
    end)

    it(
      "strips test_ prefix (python)",
      function() assert.equals("utils", related.get_core_name("tests/test_utils.py")) end
    )

    it("strips _test suffix (go/python)", function()
      assert.equals("handler", related.get_core_name("handler_test.go"))
      assert.equals("utils", related.get_core_name("tests/utils_test.py"))
    end)

    it("strips _spec suffix (busted/ruby)", function()
      assert.equals("related-files", related.get_core_name("tests/related-files_spec.lua"))
      assert.equals("utils", related.get_core_name("spec/utils_spec.rb"))
    end)

    it(
      "uses parent dir for init files",
      function()
        assert.equals("related-files", related.get_core_name("lua/stuff/related-files/init.lua"))
      end
    )

    it("uses parent dir for index files", function()
      assert.equals("Button", related.get_core_name("src/components/Button/index.tsx"))
      assert.equals("Button", related.get_core_name("src/components/Button/index.ts"))
    end)

    it(
      "uses parent dir for __init__ files",
      function() assert.equals("mypackage", related.get_core_name("lib/mypackage/__init__.py")) end
    )
  end)

  describe("get_qualifier", function()
    local root = "/project"

    it("returns directory name for non-structural parent", function()
      assert.equals("git", related.get_qualifier("/project/lua/stuff/git/util.lua", "util", root))
      assert.equals("git", related.get_qualifier("/project/tests/git/util_spec.lua", "util", root))
    end)

    it("returns empty string when only structural dirs remain", function()
      assert.equals("", related.get_qualifier("/project/lua/stuff/util/init.lua", "util", root))
      assert.equals("", related.get_qualifier("/project/tests/util_spec.lua", "util", root))
    end)

    it("skips directory matching core_name for index files", function()
      assert.equals(
        "",
        related.get_qualifier("/project/lua/stuff/related-files/init.lua", "related-files", root)
      )
      assert.equals(
        "",
        related.get_qualifier("/project/tests/related-files_spec.lua", "related-files", root)
      )
    end)

    it("returns component-style qualifier for JS projects", function()
      assert.equals(
        "components",
        related.get_qualifier("/project/src/components/Button/index.tsx", "Button", root)
      )
      assert.equals(
        "components",
        related.get_qualifier("/project/src/components/Button.test.tsx", "Button", root)
      )
    end)

    it(
      "skips lua package name dirs (child of lua/)",
      function()
        assert.equals("", related.get_qualifier("/project/lua/myplugin/init.lua", "myplugin", root))
      end
    )

    it("returns qualifier when semantic dir exists above structural", function()
      assert.equals("api", related.get_qualifier("/project/src/api/client.ts", "client", root))
      assert.equals(
        "api",
        related.get_qualifier("/project/tests/api/client_test.ts", "client", root)
      )
    end)
  end)

  describe("classify_file", function()
    it("classifies .test. files as test", function()
      assert.equals("test", related.classify_file("MyComponent.test.tsx"))
      assert.equals("test", related.classify_file("utils.test.ts"))
    end)

    it(
      "classifies .spec. files as test",
      function() assert.equals("test", related.classify_file("MyComponent.spec.tsx")) end
    )

    it("classifies _test suffix as test", function()
      assert.equals("test", related.classify_file("handler_test.go"))
      assert.equals("test", related.classify_file("utils_test.py"))
    end)

    it(
      "classifies test_ prefix as test",
      function() assert.equals("test", related.classify_file("test_utils.py")) end
    )

    it("classifies css/scss/sass/less as style", function()
      assert.equals("style", related.classify_file("MyComponent.module.css"))
      assert.equals("style", related.classify_file("MyComponent.scss"))
      assert.equals("style", related.classify_file("theme.sass"))
      assert.equals("style", related.classify_file("vars.less"))
    end)

    it("classifies _spec suffix as test", function()
      assert.equals("test", related.classify_file("related-files_spec.lua"))
      assert.equals("test", related.classify_file("utils_spec.rb"))
    end)

    it("classifies other files as code", function()
      assert.equals("code", related.classify_file("MyComponent.tsx"))
      assert.equals("code", related.classify_file("main.go"))
      assert.equals("code", related.classify_file("utils.py"))
    end)
  end)
end)
