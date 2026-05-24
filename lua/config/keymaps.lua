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
