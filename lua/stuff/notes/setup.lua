---@class NotesOptions
---@field root_dir? string

---@param start_line number
---@param end_line number
local function wrap_range_in_codeblock(start_line, end_line)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)

  vim.ui.input({ prompt = "Codeblock filetype: " }, function(filetype)
    if filetype == nil then return end

    local replacement = { "```" .. filetype }
    vim.list_extend(replacement, lines)
    table.insert(replacement, "```")

    vim.api.nvim_buf_set_lines(bufnr, start_line, end_line, false, replacement)
  end)
end

local function wrap_visual_selection_in_codeblock()
  local range = require("stuff.util.visual").get_visual_range()
  wrap_range_in_codeblock(range.start_line - 1, range.end_line)
end

local function wrap_current_line_in_codeblock()
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1
  wrap_range_in_codeblock(line, line + 1)
end

---params opts? NotesOptions
local function setup(opts)
  ---@type NotesOptions
  opts = vim.tbl_extend("force", { root_dir = vim.uv.os_homedir() .. "/notes" }, opts or {})

  vim.keymap.set(
    "n",
    "<leader>jw",
    function() require("stuff.notes.weekly").jump_to_weekly(opts.root_dir) end,
    { desc = "Jump to weekly note" }
  )

  vim.keymap.set(
    "n",
    "<leader>jd",
    function() require("stuff.notes.daily").jump_to_daily(opts.root_dir) end,
    { desc = "Jump to daily note" }
  )

  vim.keymap.set("i", "<c-x>t", "- [ ]")
  vim.cmd("abbr tsk - [ ]")
  vim.keymap.set(
    "n",
    "<leader>tt",
    function() require("stuff.notes.tasks").toggle_done() end,
    { desc = "Toggle task done" }
  )

  vim.keymap.set(
    "i",
    "<c-x>m",
    function() require("stuff.notes.insert-link").insert_link() end,
    { desc = "Insert markdown link" }
  )
  vim.keymap.set(
    "n",
    "<leader>il",
    function() require("stuff.notes.insert-link").insert_link() end,
    { desc = "Insert markdown link" }
  )
  vim.keymap.set(
    "n",
    "<leader>ii",
    function() require("stuff.notes.insert-image").insert_image() end,
    { desc = "Insert markdown image" }
  )

  vim.keymap.set(
    "n",
    "<leader>id",
    function() require("stuff.notes.daily").insert_date_header() end,
    { desc = "Insert date header" }
  )

  vim.keymap.set(
    "n",
    "<leader>cb",
    wrap_current_line_in_codeblock,
    { desc = "Wrap current line in codeblock" }
  )

  vim.keymap.set(
    "x",
    "<leader>cb",
    wrap_visual_selection_in_codeblock,
    { desc = "Wrap visual selection in codeblock" }
  )
end

return setup
