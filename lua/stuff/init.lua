---@class StuffOptions
---@field toggle_word? ToggleWordOptions
---@field open_link? OpenLinkOptions
---@field paste_image? boolean
---@field git? boolean
---@field notes? NotesOptions
---@field hebrew? boolean
---@field alternate_file? boolean
---@field scriptify? ScriptifyOptions
---@field log_line? LogLineOptions
---@field comment? boolean
---@field keymaps? boolean
---@field put? boolean
---@field messages? boolean
---@field folding? boolean
---@field lsp? boolean
---@field typescript? boolean
---@field quickfix? boolean
---@field terminal? boolean
---@field yank? boolean
---@field jira? boolean
---@field buffer? boolean
---@field prompts? boolean
---@field related_files? boolean

---@type StuffOptions
local default_options = {
  toggle_word = {},
  open_link = {},
  paste_image = true,
  git = true,
  notes = {},
  hebrew = true,
  alternate_file = true,
  scriptify = {},
  log_line = {},
  comment = true,
  keymaps = true,
  put = true,
  messages = true,
  folding = true,
  lsp = true,
  typescript = true,
  quickfix = true,
  terminal = true,
  yank = true,
  jira = true,
  buffer = true,
  prompts = true,
  related_files = true,
}

---@param opts? StuffOptions
local function setup(opts)
  opts = vim.tbl_extend("force", default_options, opts or {})

  if opts.toggle_word then require("stuff.toggle-word.setup")(opts.toggle_word) end
  if opts.open_link then require("stuff.open-link.setup")(opts.open_link) end
  if opts.paste_image then require("stuff.paste-image.setup")() end
  if opts.git then require("stuff.git.setup")() end
  if opts.notes then require("stuff.notes.setup")(opts.notes) end
  if opts.alternate_file then require("stuff.alternate-file.setup")() end
  if opts.scriptify then require("stuff.scriptify.setup")(opts.scriptify) end
  if opts.log_line then require("stuff.log-line.setup")(opts.log_line) end
  if opts.hebrew then require("stuff.hebrew.setup")() end
  if opts.comment then require("stuff.comment.setup")() end
  if opts.keymaps then require("stuff.keymaps")() end
  if opts.put then require("stuff.put") end
  if opts.messages then require("stuff.messages.setup")() end
  if opts.folding then require("stuff.folding")() end
  if opts.lsp then require("stuff.lsp")() end
  if opts.typescript then require("stuff.typescript.setup")() end
  if opts.quickfix then require("stuff.quickfix")() end
  if opts.terminal then require("stuff.terminal")() end
  if opts.yank then require("stuff.yank.setup")() end
  if opts.jira then require("stuff.jira.setup")() end
  if opts.buffer then require("stuff.buffer")() end
  if opts.prompts then require("stuff.prompts.setup")() end
  if opts.related_files then require("stuff.related-files.setup")() end
end

return { setup = setup }
