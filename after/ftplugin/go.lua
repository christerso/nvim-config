-- Go filetype keymaps.

local bufnr = vim.api.nvim_get_current_buf()
local function map(lhs, rhs, desc, mode)
  vim.keymap.set(mode or "n", lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
end

local term_win = {
  border = "rounded",
  width = 0.85,
  height = 0.75,
  wo = { winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder" },
}

local function run_file()
  vim.cmd("write")
  local file = vim.fn.expand("%:p")
  Snacks.terminal("go run " .. vim.fn.shellescape(file), {
    auto_close = false,
    win = term_win,
  })
end

local function run_package()
  vim.cmd("write")
  local dir = vim.fn.expand("%:p:h")
  Snacks.terminal("go run .", {
    cwd = dir,
    auto_close = false,
    win = term_win,
  })
end

map("<leader>rr", run_file, "Run current Go file")
map("<leader>rR", run_package, "Run current Go package")

-- Ctrl+Return launches the current Go file from normal and insert mode.
-- Works in Neovide (native modifier encoding) and CLI nvim on terminals that
-- support the kitty keyboard protocol (Alacritty >= 0.13, kitty); a plain
-- xterm can't distinguish Ctrl+Return from Return, so it silently no-ops there.
map("<C-CR>", run_file, "Run current Go file", "n")
map("<C-CR>", run_file, "Run current Go file", "i")
