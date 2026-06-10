-- Build / run dispatcher driven from <leader>m.
--
--   <leader>mm  Build (smart)         → dispatches on the project at the cursor:
--                                        • CMakeLists.txt → cmake --build (reverie)
--                                        • go.mod / *.go  → go build (see below)
--                                        • otherwise      → :make
--   <leader>mr  Run                  → dispatches like <leader>mm:
--                                        • CMake project → ./<build>/reverie
--                                        • Go project    → `go run` the current file
--                                       …in a terminal split.
--   <leader>mc  Clean (cmake)         → cmake --build --target clean
--   <leader>mg  (Re)configure cmake   → cmake -S . -B <build>
--
-- Build runs async (vim.system); compiler errors are parsed into the quickfix
-- list so you can jump to them with ]q / [q or by selecting in :copen. Build
-- finds the project root from CMakeLists.txt / go.mod / .git.
--
-- Go note: golings/solutions keep many standalone `package main` files in one
-- directory, which can't be built as a single package. So in that layout
-- <leader>mm compiles just the current file (`go build -o /dev/null <file>`);
-- in a normal module it builds everything (`go build ./...`).
--
-- The cmake build dir is shared with CLion (cmake-build-debug) so nvim and
-- CLion reuse one CMake cache. If it isn't configured yet, the cmake build
-- configures it first automatically.

local BUILD_DIR = "cmake-build-debug" -- shared with CLion's default

local function root(markers)
  return vim.fs.root(0, markers) or vim.uv.cwd()
end

-- Go's compiler error format: "path:line:col: message", with "# pkg" headers
-- and "vet:"/note lines we don't want as jumpable entries.
local GO_EFM = table.concat({ "%-G#%.%#", "%f:%l:%c: %m", "%f:%l: %m", "%-G%.%#" }, ",")

local function to_quickfix(title, out, efm)
  vim.fn.setqflist({}, " ", {
    title = title,
    lines = vim.split(out, "\n"),
    efm = efm or vim.o.errorformat, -- default handles clang/gcc output
  })
end

-- Run cmd (list) async at cwd; call done(code, combined_stdout_stderr) on the
-- main loop.
local function spawn(cmd, cwd, done)
  vim.system(cmd, { cwd = cwd, text = true }, function(res)
    vim.schedule(function()
      done(res.code, (res.stdout or "") .. "\n" .. (res.stderr or ""))
    end)
  end)
end

-- Generic "run a build command, report into quickfix" helper.
local function run_build(cmd, cwd, efm)
  vim.cmd("silent! wall") -- save all buffers first
  vim.notify("Building: " .. table.concat(cmd, " "), vim.log.levels.INFO, { title = "build" })
  spawn(cmd, cwd, function(code, out)
    to_quickfix(table.concat(cmd, " "), out, efm)
    if code == 0 then
      vim.cmd("cclose")
      vim.notify("Build OK", vim.log.levels.INFO, { title = "build" })
    else
      vim.cmd("botright copen")
      vim.notify("Build FAILED — see quickfix", vim.log.levels.ERROR, { title = "build" })
    end
  end)
end

-- ── CMake (reverie) ──────────────────────────────────────────────────────
local function cmake_configure(cwd, done)
  vim.notify("Configuring: cmake -S . -B " .. BUILD_DIR, vim.log.levels.INFO, { title = "cmake" })
  spawn({ "cmake", "-S", ".", "-B", BUILD_DIR }, cwd, function(code, out)
    if code ~= 0 then
      to_quickfix("cmake configure", out)
      vim.cmd("botright copen")
      vim.notify("Configure FAILED — see quickfix", vim.log.levels.ERROR, { title = "cmake" })
    elseif done then
      done()
    else
      vim.notify("Configured", vim.log.levels.INFO, { title = "cmake" })
    end
  end)
end

local function cmake_build(targets)
  vim.cmd("silent! wall")
  local cwd = root({ "CMakeLists.txt", ".git" })
  local function do_build()
    local cmd = { "cmake", "--build", BUILD_DIR }
    vim.list_extend(cmd, targets or {})
    run_build(cmd, cwd)
  end
  -- Auto-configure on first build if the cache isn't there yet.
  if vim.uv.fs_stat(cwd .. "/" .. BUILD_DIR .. "/CMakeCache.txt") then
    do_build()
  else
    cmake_configure(cwd, do_build)
  end
end

-- ── Go ───────────────────────────────────────────────────────────────────
-- True when the current file's directory holds more than one file with a
-- top-level `func main` — i.e. a standalone-scripts layout (golings/solutions)
-- that can't be built as a single package.
local function dir_has_multiple_mains(dir)
  local count = 0
  for _, f in ipairs(vim.fn.glob(dir .. "/*.go", false, true)) do
    local ok, lines = pcall(vim.fn.readfile, f)
    if ok then
      for _, line in ipairs(lines) do
        if line:match("^func main%(") then
          count = count + 1
          break
        end
      end
    end
    if count > 1 then
      return true
    end
  end
  return false
end

local function go_build()
  local file = vim.api.nvim_buf_get_name(0)
  local dir = vim.fn.fnamemodify(file, ":h")
  if file:match("%.go$") and dir_has_multiple_mains(dir) then
    -- Standalone file: compile just this one, no binary emitted. Absolute
    -- path so quickfix entries resolve regardless of nvim's cwd.
    local null = vim.fn.has("win32") == 1 and "NUL" or "/dev/null"
    run_build({ "go", "build", "-o", null, file }, dir, GO_EFM)
  else
    -- Normal module: build everything from the go.mod root.
    run_build({ "go", "build", "./..." }, root({ "go.mod", ".git" }), GO_EFM)
  end
end

-- ── Dispatch ─────────────────────────────────────────────────────────────
local function build_dispatch()
  if vim.fs.root(0, { "CMakeLists.txt" }) then
    cmake_build({})
  elseif vim.fs.root(0, { "go.mod" }) or vim.bo.filetype == "go" then
    go_build()
  else
    vim.cmd("silent! wall")
    vim.cmd("make")
  end
end

-- Launch CMD (a list) in a terminal split rooted at CWD, and drop into insert.
local function term_run(cmd, cwd)
  vim.cmd("botright 16split | enew")
  local ok = pcall(vim.fn.jobstart, cmd, { cwd = cwd, term = true })
  if not ok then -- fallback for older Neovim where jobstart lacks term=true
    vim.fn.termopen(cmd, { cwd = cwd })
  end
  vim.cmd("startinsert")
end

-- Run the compiled reverie binary. cwd = project root so the game finds
-- assets/ (loaded relative to the working directory); the binary path is absolute.
local function run_reverie()
  local cwd = root({ "CMakeLists.txt", ".git" })
  local bin = cwd .. "/" .. BUILD_DIR .. "/reverie"
  if not vim.uv.fs_stat(bin) then
    vim.notify("No binary yet — build first (<leader>mm)", vim.log.levels.WARN, { title = "reverie" })
    return
  end
  term_run({ bin }, cwd)
end

-- `go run` the current file. Suits the golings/solutions layout where each
-- exercise is a standalone `package main`. cwd = the file's directory so any
-- relative paths resolve there.
local function go_run()
  local file = vim.api.nvim_buf_get_name(0)
  if not file:match("%.go$") then
    vim.notify("Not a Go file — nothing to run", vim.log.levels.WARN, { title = "go run" })
    return
  end
  term_run({ "go", "run", file }, vim.fn.fnamemodify(file, ":h"))
end

-- Dispatch mirrors build_dispatch: CMake → reverie binary, Go → go run file,
-- otherwise fall back to the reverie binary (prior behaviour).
local function run()
  vim.cmd("silent! wall")
  if vim.fs.root(0, { "CMakeLists.txt" }) then
    run_reverie()
  elseif vim.fs.root(0, { "go.mod" }) or vim.bo.filetype == "go" then
    go_run()
  else
    run_reverie()
  end
end

return {
  "folke/which-key.nvim",
  optional = true,
  opts = {
    spec = {
      { "<leader>m", group = "make/run" },
    },
  },
  init = function()
    local map = vim.keymap.set
    map("n", "<leader>mm", build_dispatch, { desc = "Build (smart: cmake/go/make)" })
    map("n", "<leader>mr", run, { desc = "Run (reverie / go run file)" })
    map("n", "<leader>mc", function() cmake_build({ "--target", "clean" }) end, { desc = "Clean (cmake)" })
    map("n", "<leader>mg", function() cmake_configure(root({ "CMakeLists.txt", ".git" })) end, { desc = "(Re)configure CMake" })
  end,
}
