-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Move lines up/down with Shift+Ctrl+Up/Down
-- Normal mode: move current line
vim.keymap.set("n", "<S-C-Up>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
vim.keymap.set("n", "<S-C-Down>", ":m .+1<CR>==", { desc = "Move line down", silent = true })

-- Visual mode: move selected lines
vim.keymap.set("v", "<S-C-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })
vim.keymap.set("v", "<S-C-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })

-- Insert mode: move current line (and stay in insert mode)
vim.keymap.set("i", "<S-C-Up>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up", silent = true })
vim.keymap.set("i", "<S-C-Down>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down", silent = true })

-- Ctrl+Backspace: copy the ENTIRE buffer to the system clipboard WITHOUT moving
-- the cursor. We read the lines through the API and set the "+" register, so no
-- motion ever happens — point and view stay exactly where they were. Mapped in
-- normal, insert and visual (overrides insert-mode word-delete on this key).
local function copy_whole_buffer()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  vim.fn.setreg("+", table.concat(lines, "\n") .. "\n")
  vim.notify("Buffer copied to clipboard (" .. #lines .. " lines)", vim.log.levels.INFO)
end
vim.keymap.set({ "n", "i", "v" }, "<C-BS>", copy_whole_buffer, { desc = "Copy entire buffer to clipboard", silent = true })

-- Ctrl+Q: leave Neovim IMMEDIATELY, from any mode. Writes every modified
-- file-backed buffer first (so nothing is lost), then force-quits all windows
-- — no "press ENTER", no unsaved-changes prompt, no :q-per-window dance.
-- Scratch/unnamed buffers are discarded by the qa!.
local function save_all_and_quit()
  vim.cmd("silent! wa") -- write all named, modified buffers
  vim.cmd("qa!")
end
vim.keymap.set({ "n", "i", "v", "t" }, "<C-q>", save_all_and_quit, { desc = "Save all and quit Neovim", silent = true })
