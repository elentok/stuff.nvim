# Stuff.nvim 📦

Collection of Neovim micro-plugins

## Toggle Word ↔

Toggles boolean values (by pressing `<Leader>tw` in normal mode):

- true &harr; false
- on &harr; off
- enabled &harr; disabled
- left &harr; right
- top &harr; bottom
- margin-left &harr; margin-right
- etc...

## Installation

Using [Lazy](https://github.com/folke/lazy.nvim):

```lua
{
  "elentok/togglr.nvim",
  opts = {
    toggle_word = {}
  },
  keys = {
    { '<leader>tw' }
  }
}
```

## Default Options

```lua
{
  "elentok/togglr.nvim",
  opts = {
    -- Specify key map (set to false or nil to disable)
    key = "<Leader>tw",

    -- Specify which register to use (to avoid overriding the default register)
    register = "t",

    -- Enable debugging mode
    debug = true,

    -- Add custom sets to values to toggle between
    values = {
      ["value"] = "opposite-value",
    },
  }
}
```
