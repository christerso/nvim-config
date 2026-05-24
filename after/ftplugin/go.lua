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

map("<leader>rr", function()
  vim.cmd("write")
  local file = vim.fn.expand("%:p")
  Snacks.terminal("go run " .. vim.fn.shellescape(file), {
    auto_close = false,
    win = term_win,
  })
end, "Run current Go file")

map("<leader>rR", function()
  vim.cmd("write")
  local dir = vim.fn.expand("%:p:h")
  Snacks.terminal("go run .", {
    cwd = dir,
    auto_close = false,
    win = term_win,
  })
end, "Run current Go package")
