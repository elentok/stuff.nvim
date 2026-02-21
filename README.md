# Stuff.nvim 📦

Collection of Neovim micro-plugins

## Installation

See [stuff.lua](https://github.com/elentok/dotfiles/blob/main/core/lazyvim/lua/plugins/stuff.lua)

## Plugins

### Toggle Word ↔️

Toggles boolean values (configurable key):

- true &harr; false
- on &harr; off
- enabled &harr; disabled
- left &harr; right
- top &harr; bottom
- margin-left &harr; margin-right
- etc...

### Open Link 🔗

Open links in a browser (or copy to clipboard when in an SSH session).

The reason I wrote this plugin is that I wanted to be able to open Jira ticket
IDs and Github pull requests from my notes (or code comments) without writing
the entire URL.

For example, pressing `gx` while standing on MYJIRAPROJ-1234 will open the
ticket in the browser.

### Paste Image 🖼️

Paste an image from the clipboard and add a markdown link to it.

| Mapping       | Description                |
| ------------- | -------------------------- |
| `<leader>ip`  | Paste image from clipboard |
| `:PasteImage` | Same, as a command         |

### Git 🌿

| Mapping      | Description                           |
| ------------ | ------------------------------------- |
| `<leader>ga` | Git add file (patch)                  |
| `<leader>gu` | Git checkout file (patch)             |
| `<leader>gw` | Write + stage current file            |
| `<leader>gr` | Reset git changes (with confirmation) |
| `<leader>gy` | Yank current file's public URL        |
| `<leader>go` | Open current file's public URL        |
| `<leader>gd` | Git diff of current file              |

### Notes 🗒️

| Mapping           | Description                  |
| ----------------- | ---------------------------- |
| `<leader>jw`      | Jump to weekly note          |
| `<leader>jd`      | Jump to daily note           |
| `<leader>tt`      | Toggle task done             |
| `<leader>il`      | Insert markdown link         |
| `<leader>ii`      | Insert markdown image        |
| `<leader>id`      | Insert date header           |
| `<c-x>t` (insert) | Insert task checkbox `- [ ]` |
| `<c-x>m` (insert) | Insert markdown link         |

### Related Files 🔀

Find and jump to related files (test, code, style) based on filename conventions.
Supports TypeScript, Go, Python, and more.

| Mapping       | Description                   |
| ------------- | ----------------------------- |
| `<leader>jj`  | Jump to related file (picker) |
| `<leader>jtt` | Jump to test file             |
| `<leader>jtc` | Jump to code file             |
| `<leader>jts` | Jump to style file            |

### Alternate File 📂 (deprecated)

| Mapping      | Description                     |
| ------------ | ------------------------------- |
| `<leader>jo` | Jump between code and test file |

### Scriptify 📜

Add a shebang line and make the file executable.

| Mapping      | Description |
| ------------ | ----------- |
| `<leader>sf` | Scriptify   |

### Log Line 🔍

Insert a log line (`console.log`, `put()`, `echo`) with filename and line
context. Key is configurable.

### Comment 💬

| Mapping      | Description                                 |
| ------------ | ------------------------------------------- |
| `<leader>yc` | Duplicate line/selection and comment it out |

### Yank 📋

| Mapping               | Description                                 |
| --------------------- | ------------------------------------------- |
| `<leader>yf`          | Yank filename (with line numbers in visual) |
| `<leader>ym` (visual) | Yank as markdown                            |
| `<leader>yh` (visual) | Yank as HTML (from markdown)                |
| `<leader>ya`          | Yank entire file                            |

### TypeScript 🟦

| Mapping      | Description                        |
| ------------ | ---------------------------------- |
| `<leader>to` | Toggle `.only` on closest test     |
| `<leader>ta` | Toggle `async` on closest function |
| `<leader>un` | Upgrade npm package version        |

### AI Prompts 🤖

AI prompt manager for creating and managing prompts with file context.

| Mapping      | Description                                                 |
| ------------ | ----------------------------------------------------------- |
| `<leader>pn` | New AI prompt (line context in normal, selection in visual) |
| `<leader>pp` | Toggle AI prompt window                                     |
| `<leader>ps` | Select AI prompt (picker)                                   |

### Hebrew

| Mapping    | Description              |
| ---------- | ------------------------ |
| `<space>h` | Toggle Hebrew mode (RTL) |

### Jira

| Mapping      | Description        |
| ------------ | ------------------ |
| `<leader>jp` | Preview Jira issue |
| `<leader>oj` | Open Jira issue    |

### LSP

Keymaps attached on `LspAttach`:

| Mapping      | Description         |
| ------------ | ------------------- |
| `gd`         | Go to definition    |
| `K`          | Hover               |
| `<space>th`  | Toggle inline hints |
| `<leader>co` | Organize imports    |

### Terminal 🖥️

| Mapping | Description     |
| ------- | --------------- |
| `<c-q>` | Toggle terminal |

### Buffer 📄

| Mapping      | Description         |
| ------------ | ------------------- |
| `<leader>df` | Delete current file |

### Messages 💭

| Mapping      | Description                        |
| ------------ | ---------------------------------- |
| `<leader>wm` | Show messages in a floating window |

### Folding 🪗

Treesitter-based folding with LSP fallback. No keymaps.

### Quickfix 🔧

Quickfix window configuration. Press `q` to close.
