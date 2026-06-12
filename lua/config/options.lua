-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Borderless floats globally (Neovim 0.11+). Theme also flattens border colors
-- so older Nvim versions still get blended borders via FloatBorder = bg.
if vim.fn.has("nvim-0.11") == 1 then
  vim.o.winborder = "none"
end

-- Hide whitespace markers (tabs rendered as `>`, trailing spaces, etc.)
vim.opt.list = false

-- Keep the cursor vertically centered: a huge scrolloff forces this many
-- lines above/below the cursor, so the view scrolls to hold it in the middle.
vim.opt.scrolloff = 999

-- Neovide font configuration
-- Default family/size live in globals so the font keymaps (Ctrl+1..5, Ctrl+
-- scroll, Ctrl+0 reset — see config/keymaps.lua) can read and reset them.
vim.g.font_default_family = "MesloLGL Nerd Font Mono"
vim.g.font_default_size = 14
if vim.g.neovide then
  vim.o.guifont = vim.g.font_default_family .. ":h" .. vim.g.font_default_size
  -- Behave like a plain terminal nvim: no cursor trail, no animations.
  vim.g.neovide_cursor_vfx_mode = "" -- no particle trail (was "pixiedust")
  vim.g.neovide_cursor_animation_length = 0 -- cursor jumps instantly, no smear
  vim.g.neovide_cursor_trail_size = 0
  vim.g.neovide_scroll_animation_length = 0 -- no smooth scroll
  vim.g.neovide_position_animation_length = 0 -- no window/split slide
end

-- x86-64 assembly: default .asm files to NASM (Intel syntax). The builtin
-- .asm filetype detector consults g:asmsyntax before its own heuristics.
-- GAS/AT&T files keep using .s/.S (ft=asm). See lua/plugins/asm.lua.
vim.g.asmsyntax = "nasm"
vim.filetype.add({ extension = { nasm = "nasm" } })
