local map = vim.keymap.set

local function setup()
  -- Window movement
  map("n", "<leader>wh", "<c-w>h", { desc = "Go to window to the left" })
  map("n", "<leader>wj", "<c-w>j", { desc = "Go to window below" })
  map("n", "<leader>wk", "<c-w>k", { desc = "Go to window above" })
  map("n", "<leader>wl", "<c-w>l", { desc = "Go to window to the right" })

  -- map("n", "<c-h>", "<c-w>h", { desc = "Go to window to the left" })
  -- map("n", "<c-j>", "<c-w>j", { desc = "Go to window below" })
  -- map("n", "<c-k>", "<c-w>k", { desc = "Go to window above" })
  -- map("n", "<c-l>", "<c-w>l", { desc = "Go to window to the right" })

  map("n", "<leader>wo", "<c-w>o", { desc = "Only window" })
  map("n", "<leader>ws", "<c-w>s", { desc = "Split window" })
  map("n", "<leader>wv", "<c-w>v", { desc = "Split window vertically" })

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
  map({ "x", "n", "s" }, "<C-s>", ":w<cr>", { desc = "Save File" })
  map({ "i" }, "<C-s>", "<c-o>:w<cr>", { desc = "Save File" })

  -- visual mode
  map({ "n", "v" }, "<leader>vv", "<c-v>", { desc = "Go into block visual mode" })
  map("n", "vv", "V", { desc = "Go into visual line mode" })
  map("n", "vb", "<c-v>", { desc = "Go into visual block mode" })

  map(
    "n",
    "<leader>ur",
    "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
    { desc = "Redraw / Clear hlsearch / Diff Update" }
  )
end

return setup
