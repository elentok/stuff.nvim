# Stuff.nvim 📦

Collection of Neovim micro-plugins

## Installation

Using [Lazy](https://github.com/folke/lazy.nvim):

```lua
{
  "elentok/stuff.nvim",
  config = function()
    local expanders = require("stuff.open-link.expanders")

    require("stuff").setup({
      toggle_word = {
        -- Specify key map (set to false or nil to disable)
        key = "<Leader>tw",

        -- Specify which register to use (to avoid overriding the default register)
        register = "t",

        -- Set to true to enable debugging mode
        debug = false,

        -- Add custom sets to values to toggle between
        values = {
          ["value"] = "opposite-value",
        },
      }
      paste_image = true,
      open_link = {
        expanders = {
          -- expand ~/bob to $HOME/bob
          expanders.homedir(),

          -- expands "{user}/{repo}" to the github repo URL
          expanders.github,

          -- expands "format-on-save#15" the issue/pr #15 in the specified github project
          -- ("format-on-save" is the shortcut/keyword)
          expanders.github_issue_or_pr("format-on-save", "elentok/format-on-save.nvim"),

          -- expands "MYJIRA-1234" and "myotherjira-1234" to the specified Jira URL
          expanders.jira("https://myjira.atlassian.net/browse/", { "myjira", "myotherjira"})
        },
      }
    })
  end,
  keys = {
    { '<leader>tw' },
    { "gx" },
    {
      "<Leader>ip",
      "<cmd>PasteImage<cr>",
      desc = "Paste image from clipboard",
    },
  }
}
```

## Toggle Word ↔

Toggles boolean values (by pressing `<Leader>tw` in normal mode):

- true &harr; false
- on &harr; off
- enabled &harr; disabled
- left &harr; right
- top &harr; bottom
- margin-left &harr; margin-right
- etc...

## Open Link

Open links in a browser (or copy to clipboard when in an SSH session).

The reason I wrote this plugin is that I wanted to be able to open Jira ticket
IDs and Github pull requests from my notes (or code comments) without writing
the entire URL.

For example, pressing `ge` while standing on MYJIRAPROJ-1234 will open the
ticket in the browser. See example below.

## Paste Image

You can use the `:PasteImage` command to paste an image from the clipboard to a
file and add a markdown link to that image (`![file.png](file.png)`).
