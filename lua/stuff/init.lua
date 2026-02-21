---@class StuffOptions
---@field alternate_file? boolean
---@field buffer? boolean
---@field comment? boolean
---@field folding? boolean
---@field git? boolean
---@field hebrew? boolean
---@field jira? boolean
---@field keymaps? boolean
---@field log_line? LogLineOptions
---@field lsp? boolean
---@field messages? boolean
---@field notes? NotesOptions
---@field open_link? OpenLinkOptions
---@field paste_image? boolean
---@field prompts? boolean
---@field put? boolean
---@field quickfix? boolean
---@field related_files? boolean
---@field scriptify? ScriptifyOptions
---@field terminal? boolean
---@field toggle_word? ToggleWordOptions
---@field typescript? boolean
---@field yank? boolean

---@type StuffOptions
local default_options = {
  alternate_file = true,
  buffer = true,
  comment = true,
  folding = true,
  git = true,
  hebrew = true,
  jira = true,
  keymaps = true,
  log_line = {},
  lsp = true,
  messages = true,
  notes = {},
  open_link = {},
  paste_image = true,
  prompts = true,
  put = true,
  quickfix = true,
  related_files = true,
  scriptify = {},
  terminal = true,
  toggle_word = {},
  typescript = true,
  yank = true,
}

---@param opts? StuffOptions
local function setup(opts)
  opts = vim.tbl_extend("force", default_options, opts or {})

  if opts.alternate_file then require("stuff.alternate-file.setup")() end
  if opts.buffer then require("stuff.buffer")() end
  if opts.comment then require("stuff.comment.setup")() end
  if opts.folding then require("stuff.folding")() end
  if opts.git then require("stuff.git.setup")() end
  if opts.hebrew then require("stuff.hebrew.setup")() end
  if opts.jira then require("stuff.jira.setup")() end
  if opts.keymaps then require("stuff.keymaps")() end
  if opts.log_line then require("stuff.log-line.setup")(opts.log_line) end
  if opts.lsp then require("stuff.lsp")() end
  if opts.messages then require("stuff.messages.setup")() end
  if opts.notes then require("stuff.notes.setup")(opts.notes) end
  if opts.open_link then require("stuff.open-link.setup")(opts.open_link) end
  if opts.paste_image then require("stuff.paste-image.setup")() end
  if opts.prompts then require("stuff.prompts.setup")() end
  if opts.put then require("stuff.put") end
  if opts.quickfix then require("stuff.quickfix")() end
  if opts.related_files then require("stuff.related-files.setup")() end
  if opts.scriptify then require("stuff.scriptify.setup")(opts.scriptify) end
  if opts.terminal then require("stuff.terminal")() end
  if opts.toggle_word then require("stuff.toggle-word.setup")(opts.toggle_word) end
  if opts.typescript then require("stuff.typescript.setup")() end
  if opts.yank then require("stuff.yank.setup")() end
end

return { setup = setup }
