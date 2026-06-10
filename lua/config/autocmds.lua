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

-- ─────────────────────────────────────────────────────────────────────────
-- C/C++: zero-interaction compile_commands.json for clangd.
-- clangd's full project index (references, jump into library/system headers,
-- cross-TU completion) needs a compilation database. On opening a C/C++ file:
--   1. root already has compile_commands.json → nothing to do.
--   2. a build dir has one → symlink it into the root silently.
--   3. CMake project with none anywhere → run `cmake -B build
--      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON` in the background, link the result
--      and restart clangd so it picks the database up.
-- Mirrors ~/.emacs.d/lisp/cpp-compdb.el — same behavior in both editors.
-- ─────────────────────────────────────────────────────────────────────────
local compdb_attempted = {}

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function(ev)
    local fname = vim.api.nvim_buf_get_name(ev.buf)
    if fname == "" then return end
    local root = vim.fs.root(fname, "CMakeLists.txt") or vim.fs.root(fname, ".git")
    if not root or compdb_attempted[root] then return end
    compdb_attempted[root] = true

    local target = root .. "/compile_commands.json"
    if vim.uv.fs_stat(target) then return end

    local function link_and_restart(db)
      vim.uv.fs_symlink(db, target)
      vim.notify("clangd: linked compile_commands.json -> " .. db, vim.log.levels.INFO)
      vim.schedule(function()
        vim.cmd("LspRestart clangd")
      end)
    end

    -- An existing database in a conventional build dir? Just link it.
    for _, dir in ipairs({ "build", "build-debug", "build-release", "out", "cmake-build-debug", "cmake-build-release" }) do
      local db = root .. "/" .. dir .. "/compile_commands.json"
      if vim.uv.fs_stat(db) then
        link_and_restart(db)
        return
      end
    end

    -- CMake project with no database: configure quietly in the background.
    if not vim.uv.fs_stat(root .. "/CMakeLists.txt") or vim.fn.executable("cmake") ~= 1 then
      return
    end
    vim.notify("clangd: generating compile_commands.json ...", vim.log.levels.INFO)
    vim.system(
      { "cmake", "-S", ".", "-B", "build", "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" },
      { cwd = root },
      vim.schedule_wrap(function(out)
        local db = root .. "/build/compile_commands.json"
        if out.code == 0 and vim.uv.fs_stat(db) then
          link_and_restart(db)
        else
          vim.notify("clangd: cmake configure failed:\n" .. (out.stderr or ""), vim.log.levels.WARN)
        end
      end)
    )
  end,
})
