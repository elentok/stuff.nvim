local map = vim.keymap.set

local function setup()
  -- Window movement
  map("n", "<leader>wH", "<c-w>H", { desc = "Move Window left" })
  map("n", "<leader>wJ", "<c-w>J", { desc = "Move Window down" })
  map("n", "<leader>wK", "<c-w>K", { desc = "Move Window up" })
  map("n", "<leader>wL", "<c-w>L", { desc = "Move Window right" })

  map("n", "<leader>we", "<c-w>=", { desc = "Window equal size" })
  map("n", "<leader>w.", "5<c-w>>", { desc = "Make window wider" })
  map("n", "<leader>w,", "5<c-w><", { desc = "Make window thinner" })
  map("n", "<leader>wi", "5<c-w>+", { desc = "Make window taller" })
  map("n", "<leader>wu", "5<c-w>-", { desc = "Make window shorter" })

  -- Save file variations
  map("n", "<leader>ww", ":w<cr>", { desc = ":w" })
  map("n", "<leader>wq", ":wq<cr>", { desc = ":wq" })
  map("n", "<leader>wa", ":wa<cr>", { desc = ":wa" })
  map("n", "<leader>qa", ":qa<cr>", { desc = ":qa" })
  map("n", "<leader>cq", ":cq<cr>", { desc = ":cq" })
  map("n", "<leader>qq", ":q<cr>", { desc = ":q" })

  -- Inspired by Helix
  map({ "n", "v" }, "gh", "0", { desc = "Go to beginning of the line" })
  map({ "n", "v" }, "ge", "G", { desc = "Go to end of the file" })
  map({ "n", "v" }, "gl", "$", { desc = "Go to end of the line" })

  -- Do not overwrite the clipboard
  map("v", "p", '"_dP')
  map("v", "P", '"_dp')
  map({ "v", "n" }, "c", '"_c')
  map({ "v", "n" }, "C", '"_C')
  map({ "v", "n" }, "<leader>d", '"_d')

  -- Add undo break-points
  map("i", ",", ",<c-g>u")
  map("i", ".", ".<c-g>u")
  map("i", ";", ";<c-g>u")

  -- save file
  map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

  -- visual mode
  map({ "n", "v" }, "<leader>vv", "<c-v>", { desc = "Go into block visual mode" })
  map("n", "vv", "V", { desc = "Go into visual line mode" })
  map("n", "vb", "<c-v>", { desc = "Go into visual block mode" })
end

return setup
