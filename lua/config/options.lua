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

-- Neovide font configuration
if vim.g.neovide then
  vim.o.guifont = "MesloLGL Nerd Font Mono:h12"
  vim.g.neovide_cursor_vfx_mode = "pixiedust"
  vim.g.neovide_cursor_vfx_particle_density = 20.0
  vim.g.neovide_cursor_vfx_particle_lifetime = 1.5
end
