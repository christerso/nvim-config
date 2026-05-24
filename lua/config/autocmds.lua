-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Go: Use tabs (Go standard) with 4-space display width
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.tabstop = 4     -- Display width of tab character
    vim.opt_local.shiftwidth = 4  -- Indentation width
    vim.opt_local.softtabstop = 4 -- Backspace removes 4 spaces
    vim.opt_local.expandtab = false -- Use actual tabs, not spaces (Go standard)
  end,
})

-- Go: auto-add/remove imports on save via gopls (source.organizeImports).
-- Runs before conform's formatter so the import edits are picked up by gofumpt.
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local clients = vim.lsp.get_clients({ bufnr = 0, name = "gopls" })
    if #clients == 0 then return end
    local enc = clients[1].offset_encoding or "utf-16"

    local params = vim.lsp.util.make_range_params(0, enc)
    params.context = { only = { "source.organizeImports" }, diagnostics = {} }

    local results = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 2000)
    for _, res in pairs(results or {}) do
      for _, action in pairs(res.result or {}) do
        if action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, enc)
        elseif type(action.command) == "table" then
          vim.lsp.buf.execute_command(action.command)
        end
      end
    end
  end,
})
