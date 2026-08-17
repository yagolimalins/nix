-- ABNT2 navigation — mirrors modules/home/helix/default.nix (JKLÇ)
local map = vim.keymap.set
local opts = { silent = true }
local nop = "<Nop>"

local move = { j = "h", k = "j", l = "k", ç = "l" }

-- Normal + visual: j/k/l/ç = ← ↓ ↑ →
for _, mode in ipairs({ "n", "v" }) do
  map(mode, "h", nop, opts)
  for key, motion in pairs(move) do
    map(mode, key, motion, vim.tbl_extend("force", opts, { desc = "move" }))
  end
end

-- g prefix (helix goto mode) — 2×2 spatial: j/ç line, k/l file
map("n", "gj", "0", vim.tbl_extend("force", opts, { desc = "Line start" }))
map("n", "gç", "$", vim.tbl_extend("force", opts, { desc = "Line end" }))
map("n", "gl", "gg", vim.tbl_extend("force", opts, { desc = "File start" }))
map("n", "gk", "G", vim.tbl_extend("force", opts, { desc = "File end" }))

-- z prefix (helix view mode scroll)
map("n", "zh", nop, opts)
map("n", "zj", nop, opts)
map("n", "zk", "<C-e>", vim.tbl_extend("force", opts, { desc = "Scroll down" }))
map("n", "zl", "<C-y>", vim.tbl_extend("force", opts, { desc = "Scroll up" }))

-- Window: jump split without Ctrl-w (Ctrl + JKLÇ)
map("n", "<C-j>", "<C-w>j", vim.tbl_extend("force", opts, { desc = "Win ←" }))
map("n", "<C-k>", "<C-w>k", vim.tbl_extend("force", opts, { desc = "Win ↓" }))
map("n", "<C-l>", "<C-w>l", vim.tbl_extend("force", opts, { desc = "Win ↑" }))
map("n", "<C-ç>", "<C-w>ç", vim.tbl_extend("force", opts, { desc = "Win →" }))

-- Window: jump split (Ctrl-w + JKLÇ)
map("n", "<C-w>h", nop, opts)
map("n", "<C-w>j", "<C-w>h", vim.tbl_extend("force", opts, { desc = "Win ←" }))
map("n", "<C-w>k", "<C-w>j", vim.tbl_extend("force", opts, { desc = "Win ↓" }))
map("n", "<C-w>l", "<C-w>k", vim.tbl_extend("force", opts, { desc = "Win ↑" }))
map("n", "<C-w>ç", "<C-w>l", vim.tbl_extend("force", opts, { desc = "Win →" }))

-- Window: swap split (Ctrl-w prefix only)
map("n", "<C-w>H", nop, opts)
map("n", "<C-w>J", nop, opts)
map("n", "<C-w>K", nop, opts)
map("n", "<C-w>L", nop, opts)
map("n", "<C-w><C-j>", "<C-w>H", vim.tbl_extend("force", opts, { desc = "Swap ←" }))
map("n", "<C-w><C-k>", "<C-w>J", vim.tbl_extend("force", opts, { desc = "Swap ↓" }))
map("n", "<C-w><C-l>", "<C-w>K", vim.tbl_extend("force", opts, { desc = "Swap ↑" }))
map("n", "<C-w><C-ç>", "<C-w>L", vim.tbl_extend("force", opts, { desc = "Swap →" }))
