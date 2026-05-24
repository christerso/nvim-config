-- Rust filetype keymaps (rustaceanvim).
-- These replace the old rust-tools.nvim mappings that lived in
-- lua/plugins/languages.lua under the rust_analyzer LSP block.

local bufnr = vim.api.nvim_get_current_buf()
local function map(lhs, rhs, desc, mode)
  vim.keymap.set(mode or "n", lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
end

-- Hover actions: press K once for hover, twice to focus the hover window.
map("K", function() vim.cmd.RustLsp({ "hover", "actions" }) end, "Hover Actions (Rust)")

-- Code actions (grouped — rustaceanvim splits them more usefully than the LSP default).
map("<leader>cA", function() vim.cmd.RustLsp("codeAction") end, "Code Action (Rust)")

-- Run / debug / test the nearest target.
map("<leader>dr", function() vim.cmd.RustLsp("debuggables") end, "Debug Target (Rust)")
map("<leader>rr", function() vim.cmd.RustLsp("runnables") end, "Run Target (Rust)")
map("<leader>tt", function() vim.cmd.RustLsp("testables") end, "Test Target (Rust)")

-- Diagnostics: render the full rendered diagnostic, or explain a compiler error code.
map("<leader>cd", function() vim.cmd.RustLsp("renderDiagnostic") end, "Render Diagnostic (Rust)")
map("<leader>cE", function() vim.cmd.RustLsp("explainError") end, "Explain Error (Rust)")

-- Macro expansion (recursive) — invaluable for proc-macro / declarative macro debugging.
map("<leader>cm", function() vim.cmd.RustLsp("expandMacro") end, "Expand Macro (Rust)")

-- Open the Cargo.toml that owns the current crate.
map("<leader>co", function() vim.cmd.RustLsp("openCargo") end, "Open Cargo.toml (Rust)")

-- Move statements/items up and down within their parent block.
map("<A-k>", function() vim.cmd.RustLsp({ "moveItem", "up" }) end, "Move Item Up (Rust)")
map("<A-j>", function() vim.cmd.RustLsp({ "moveItem", "down" }) end, "Move Item Down (Rust)")
