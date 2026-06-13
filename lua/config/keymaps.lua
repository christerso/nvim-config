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

-- <leader>ct: pick a filetype by hand (fuzzy-selectable). Handy after pasting
-- code into a scratch buffer when content auto-detect can't decide or guessed
-- wrong. Setting the filetype fires FileType, which starts Treesitter / syntax.
vim.keymap.set("n", "<leader>ct", function()
  local fts = vim.fn.getcompletion("", "filetype")
  vim.ui.select(fts, { prompt = "Set filetype:" }, function(choice)
    if choice and choice ~= "" then
      vim.bo.filetype = choice
    end
  end)
end, { desc = "Set filetype (pick)" })

-- ──────────────────────────────────────────────────────────────────────────
-- Neovide font controls. GUI only: in terminal nvim the terminal emulator
-- owns the font, so none of this applies there.
--   Ctrl+ScrollWheel   grow / shrink font size (browser-style zoom)
--   Ctrl+= / Ctrl+-    same, from the keyboard
--   Ctrl+0             reset to the default family/size from options.lua
--   Ctrl+1 .. Ctrl+5   switch between five fonts (size preserved):
--                      JetBrains Mono, Fira Code, Cascadia Code, Hack, Meslo
-- ──────────────────────────────────────────────────────────────────────────
if vim.g.neovide then
  -- guifont is always "Family:hN"; parse it, mutate, write back.
  local function current_font()
    local family, size = vim.o.guifont:match("^(.*):h(%d+)$")
    return family or vim.g.font_default_family, tonumber(size) or vim.g.font_default_size
  end

  local function set_font(family, size)
    size = math.max(6, math.min(40, size))
    vim.o.guifont = family .. ":h" .. size
    vim.notify(family .. " " .. size, vim.log.levels.INFO, { title = "Font" })
  end

  local function bump_size(delta)
    local family, size = current_font()
    set_font(family, size + delta)
  end

  local modes = { "n", "i", "v", "t" }

  vim.keymap.set(modes, "<C-ScrollWheelUp>", function() bump_size(1) end, { desc = "Font size +1", silent = true })
  vim.keymap.set(modes, "<C-ScrollWheelDown>", function() bump_size(-1) end, { desc = "Font size -1", silent = true })
  vim.keymap.set(modes, "<C-=>", function() bump_size(1) end, { desc = "Font size +1", silent = true })
  vim.keymap.set(modes, "<C-->", function() bump_size(-1) end, { desc = "Font size -1", silent = true })
  vim.keymap.set(modes, "<C-0>", function()
    set_font(vim.g.font_default_family, vim.g.font_default_size)
  end, { desc = "Font reset", silent = true })

  -- All Nerd Font Mono variants so LazyVim's icons keep rendering.
  local families = {
    "JetBrainsMono Nerd Font Mono", -- JetBrains Mono
    "FiraCode Nerd Font Mono", -- Fira Code
    "CaskaydiaCove Nerd Font Mono", -- Cascadia Code
    "Hack Nerd Font Mono", -- Hack
    "MesloLGL Nerd Font Mono", -- Meslo (the long-time default here)
  }
  for i, family in ipairs(families) do
    vim.keymap.set(modes, "<C-" .. i .. ">", function()
      local _, size = current_font()
      set_font(family, size)
    end, { desc = "Font: " .. family, silent = true })
  end
end
