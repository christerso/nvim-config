-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- NOTE: session auto-restore lives in lua/plugins/persistence.lua, NOT here:
-- this file is loaded on the VeryLazy event, which fires AFTER VimEnter, so a
-- VimEnter autocmd registered here would never run.

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
-- Auto-detect filetype from CONTENT for unnamed / extension-less buffers.
--
-- Problem: open `nvim` with no file (or `:enew`) and paste Go in — the buffer
-- has no name, so Neovim never assigns a `filetype`, so neither Treesitter nor
-- the built-in `syntax` files run. You get white text. Go (like C/Rust/Zig)
-- has no shebang, so Neovim's built-in content matcher can't catch it either.
--
-- Fix: on text change in a normal buffer that still has an empty `filetype`,
-- (a) let Neovim's own content matcher try first (handles shebangs/modelines),
-- then (b) fall back to a keyword/pattern scorer covering the languages used
-- here. We only act while `filetype` is still empty, so once a type is set
-- (by us, by an extension, or by hand) we never touch the buffer again — no
-- flip-flopping mid-edit. Setting `filetype` fires the FileType event, which is
-- exactly what drives Treesitter (LazyVim) and the classic syntax fallback.
-- ─────────────────────────────────────────────────────────────────────────
local detect_filetype = (function()
  -- Each entry: { ft, patterns = { {lua_pattern, weight, anchored?}, ... } }.
  -- Anchored patterns are tested per-line with `^`; others over the whole text.
  -- A pattern contributes its weight at most once, so a file full of `:=`
  -- can't drown out a single strong signal like `package foo`.
  local LANGS = {
    {
      ft = "go",
      patterns = {
        { "^package%s+[%w_]+%s*$", 6, true },
        { "^import%s+%(", 5, true },
        { "%f[%w]func%s", 3 },
        { ":=", 3 },
        { "%f[%w]fmt%.", 4 },
        { "%f[%w]interface%s*{", 3 },
        { "%f[%w]chan%s", 3 },
        { "%f[%w]go%s+func", 4 },
      },
    },
    {
      ft = "rust",
      patterns = {
        { "%f[%w]fn%s+[%w_]", 3 },
        { "%f[%w]let%s+mut%s", 5 },
        { "%f[%w]impl%s", 4 },
        { "%f[%w]pub%s+fn%s", 4 },
        { "[%w_]!%s*%(", 3 }, -- macro call: println!( etc.
        { "%f[%w]use%s+[%w_]+::", 4 },
        { "&str", 3 },
        { "Vec<", 3 },
        { "%f[%w]match%s", 2 },
      },
    },
    {
      ft = "cpp",
      patterns = {
        { "std::", 5 },
        { "%f[%w]template%s*<", 5 },
        { "%f[%w]using%s+namespace", 5 },
        { "%f[%w]c?out%s*<<", 4 },
        { "%f[%w]class%s+[%w_]", 3 },
        { "%f[%w]namespace%s+[%w_]", 4 },
        { "#include%s*<", 2 },
        { "%f[%w]nullptr%f[%W]", 3 },
      },
    },
    {
      ft = "c",
      patterns = {
        { "#include%s*[<\"]", 4 },
        { "#define%s", 3 },
        { "%f[%w]int%s+main%s*%(", 3 },
        { "%f[%w]printf%s*%(", 3 },
        { "%f[%w]struct%s+[%w_]+%s*{", 3 },
        { "%f[%w]typedef%s", 3 },
        { "%f[%w]malloc%s*%(", 3 },
      },
    },
    {
      ft = "zig",
      patterns = {
        { "@import%s*%(", 6 },
        { "%f[%w]const%s+[%w_]+%s*=%s*@", 5 },
        { "%f[%w]pub%s+fn%s", 3 },
        { "%f[%w]comptime%f[%W]", 5 },
        { "%f[%w]anytype%f[%W]", 5 },
        { "!void", 4 },
        { "%f[%w]try%s", 2 },
      },
    },
    {
      ft = "odin",
      patterns = {
        { "::%s*proc%s*%(", 6 },
        { "%f[%w]proc%s*%(", 4 },
        { "import%s+\"core:", 6 },
        { "%f[%w]package%s+[%w_]", 2, true },
      },
    },
    {
      ft = "python",
      patterns = {
        { "^%s*def%s+[%w_]+%s*%(", 5, true },
        { "^%s*from%s+[%w_.]+%s+import%s", 5, true },
        { "^%s*import%s+[%w_]", 3, true },
        { "%f[%w]self%.", 3 },
        { "__[%w_]+__", 3 },
        { "^%s*class%s+[%w_]+%s*[:(]", 3, true },
        { "%f[%w]elif%f[%W]", 4 },
      },
    },
    {
      ft = "lua",
      patterns = {
        { "%f[%w]local%s+[%w_]", 3 },
        { "%f[%w]function%s", 2 },
        { "%f[%w]end%f[%W]", 2 },
        { "%f[%w]vim%.", 5 },
        { "%f[%w]require%s*%(?[\"']", 3 },
        { "%f[%w]then%f[%W]", 2 },
        { "~=", 3 },
      },
    },
    {
      ft = "typescript",
      patterns = {
        { "%f[%w]interface%s+[%w_]", 4 },
        { ":%s*%w+%s*[=;)]", 3 }, -- type annotations
        { "%f[%w]enum%s+[%w_]", 4 },
        { "%f[%w]const%s+[%w_]+%s*:", 4 },
        { "%f[%w]export%s+", 2 },
        { "%f[%w]import%s+.+%s+from%s", 2 },
      },
    },
    {
      ft = "javascript",
      patterns = {
        { "%f[%w]console%.log", 4 },
        { "=>%s*{", 3 },
        { "%f[%w]const%s+[%w_]+%s*=", 2 },
        { "%f[%w]function%s", 2 },
        { "%f[%w]require%s*%(", 3 },
        { "%f[%w]let%s+[%w_]+%s*=", 2 },
        { "module%.exports", 4 },
      },
    },
    {
      ft = "sh",
      patterns = {
        { "^%s*if%s+%[%[?", 3, true },
        { "%f[%w]fi%f[%W]", 3 },
        { "%f[%w]echo%s", 2 },
        { "%f[%w]then%f[%W]", 1 },
        { "%$%b{}", 2 },
        { "%$%(", 2 },
      },
    },
    {
      ft = "json",
      patterns = {
        { "^%s*{%s*$", 2, true },
        { "\"[%w_]+\"%s*:%s*[%[{\"%d-]", 4 },
      },
    },
    {
      ft = "yaml",
      patterns = {
        { "^%s*[%w_-]+:%s*$", 3, true },
        { "^%s*[%w_-]+:%s+%S", 3, true },
        { "^%s*-%s+[%w_]", 2, true },
      },
    },
    {
      ft = "sql",
      patterns = {
        { "[Ss][Ee][Ll][Ee][Cc][Tt]%s", 4 },
        { "[Ff][Rr][Oo][Mm]%s", 3 },
        { "[Cc][Rr][Ee][Aa][Tt][Ee]%s+[Tt][Aa][Bb][Ll][Ee]", 5 },
        { "[Ii][Nn][Ss][Ee][Rr][Tt]%s+[Ii][Nn][Tt][Oo]", 5 },
      },
    },
    {
      ft = "html",
      patterns = {
        { "<!DOCTYPE", 5 },
        { "<html", 5 },
        { "</%a+>", 2 },
        { "<%a+[%s>]", 1 },
      },
    },
  }

  ---@param buf integer
  ---@return string|nil
  return function(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, 200, false)
    local text = table.concat(lines, "\n")
    if #text < 16 then
      return nil -- too little to judge
    end

    -- 1) Keyword/pattern scorer for the languages used here (runs first, so a
    --    confident match wins over the built-in matcher's generic guesses).
    local best, best_score, runner_up = nil, 0, 0
    for _, lang in ipairs(LANGS) do
      local score = 0
      for _, p in ipairs(lang.patterns) do
        local pat, weight, anchored = p[1], p[2], p[3]
        local hit = false
        if anchored then
          for _, line in ipairs(lines) do
            if line:find(pat) then
              hit = true
              break
            end
          end
        else
          hit = text:find(pat) ~= nil
        end
        if hit then
          score = score + weight
        end
      end
      if score > best_score then
        best, runner_up, best_score = lang.ft, best_score, score
      elseif score > runner_up then
        runner_up = score
      end
    end

    -- Be conservative: only commit when one language clearly wins. This avoids
    -- mislabelling a snippet that looks a little like several languages.
    if best and best_score >= 5 and best_score >= runner_up + 2 then
      return best
    end

    -- 2) Fall back to Neovim's own content matcher (shebangs, modelines, and
    --    languages outside the table above). Reject its generic "conf"/"text"
    --    catch-all guesses, which fire on almost anything and are usually wrong.
    local ok, builtin = pcall(vim.filetype.match, { buf = buf, contents = lines })
    if ok and builtin and builtin ~= "" and builtin ~= "conf" and builtin ~= "text" then
      return builtin
    end
    return nil
  end
end)()

-- Run the detector and apply the result. Returns the chosen filetype or nil.
local function apply_detected_filetype(buf, notify)
  buf = buf or vim.api.nvim_get_current_buf()
  local ft = detect_filetype(buf)
  if ft then
    vim.bo[buf].filetype = ft
    if notify then
      vim.notify("Filetype detected: " .. ft, vim.log.levels.INFO, { title = "Auto filetype" })
    end
  elseif notify then
    vim.notify("Could not detect filetype from content", vim.log.levels.WARN, { title = "Auto filetype" })
  end
  return ft
end

do
  local timers = {}
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = vim.api.nvim_create_augroup("auto_detect_filetype", { clear = true }),
    callback = function(ev)
      -- Only normal, modifiable buffers that still have no filetype.
      if vim.bo[ev.buf].filetype ~= "" or vim.bo[ev.buf].buftype ~= "" or not vim.bo[ev.buf].modifiable then
        return
      end
      -- Debounce: pasting fires many TextChanged events in a burst.
      local t = timers[ev.buf]
      if t then
        t:stop()
        t:close()
      end
      timers[ev.buf] = vim.defer_fn(function()
        timers[ev.buf] = nil
        if vim.api.nvim_buf_is_valid(ev.buf) and vim.bo[ev.buf].filetype == "" then
          apply_detected_filetype(ev.buf, false)
        end
      end, 200)
    end,
  })
end

-- Manual triggers for when auto-detect can't decide or guessed wrong:
--   :DetectFiletype  — re-run content detection on the current buffer.
--   <leader>ct       — pick a filetype by hand from a fuzzy list.
vim.api.nvim_create_user_command("DetectFiletype", function()
  apply_detected_filetype(0, true)
end, { desc = "Detect filetype from buffer content" })

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
