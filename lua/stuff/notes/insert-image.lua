---@param image_rel_path string
local function insert_image_to_file(image_rel_path)
  local title = vim.fs.basename(image_rel_path)
  local markdown_image = string.format("![%s](%s)", title, image_rel_path)

  -- "c" = character wise, true = paste after cursor, false = do not move cursor to the end
  vim.api.nvim_put({ markdown_image }, "c", true, false)
end

local function insert_image()
  local buf_file = vim.api.nvim_buf_get_name(0)
  local buf_dir = vim.fn.fnamemodify(buf_file, ":h")

  Snacks.picker.files({
    cwd = buf_dir,
    confirm = function(picker, item)
      local image = item.cwd .. "/" .. item.file
      local rel_path = require("stuff.util.path").relative_path(buf_dir, image)

      picker:close()
      vim.defer_fn(function() insert_image_to_file(rel_path) end, 1)
    end,
    ft = { "jpg", "png", "jpeg", "webp" },
  })
end

return {
  insert_image = insert_image,
}
