rockspec_format = "3.0"
package = "stuff.nvim"
version = "scm-1"

source = {
  url = "git+https://github.com/user/stuff.nvim",
}

build = {
  type = "builtin",
}

test_dependencies = {
  "busted >= 2.0.0",
  "luassert >= 1.7.11",
}

test = {
  type = "busted",
}
