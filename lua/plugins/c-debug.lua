-- C/C++ debugging (DAP) using the system lldb-dap, with gdb as a fallback.
--
-- Why not codelldb?  codelldb needs a Mason download. You already have
-- /usr/bin/lldb-dap (from the lldb package) and gdb 17 (which speaks DAP via
-- --interpreter=dap), so debugging works offline with zero extra installs.
--
-- This extends LazyVim's dap.core extra additively via `opts` (a function),
-- which LazyVim runs in addition to its own dap setup — it does NOT clobber
-- signs, dap-ui, or launch.json support.
--
-- Workflow:
--   1. build a debug binary:  make           (debug = -g3, no optimization)
--   2. open a .c file, press  <leader>db      to set a breakpoint
--   3. press                  <leader>dc      → pick "Launch (lldb-dap)"
--      → type the path (defaults to <cwd>/build/, e.g. build/reverie)
--   dap-ui opens automatically; step with <leader>di/dO/do, stop <leader>dt.

local function pick_executable()
  return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
end

return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")

      -- ── adapters ──────────────────────────────────────────────────────────
      if not dap.adapters.lldb then
        dap.adapters.lldb = {
          type = "executable",
          command = "/usr/bin/lldb-dap",
          name = "lldb",
        }
      end

      if not dap.adapters.gdb then
        -- gdb >= 14 implements the Debug Adapter Protocol natively
        dap.adapters.gdb = {
          type = "executable",
          command = "gdb",
          args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
        }
      end

      -- ── configurations (shared by c and cpp) ─────────────────────────────
      local configs = {
        {
          name = "Launch (lldb-dap)",
          type = "lldb",
          request = "launch",
          program = pick_executable,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
          -- ASan-friendly: let the runtime print to the debug console
          env = { ASAN_OPTIONS = "abort_on_error=1:detect_leaks=1" },
        },
        {
          name = "Attach to process (lldb-dap)",
          type = "lldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
        {
          name = "Launch (gdb)",
          type = "gdb",
          request = "launch",
          program = pick_executable,
          cwd = "${workspaceFolder}",
          stopAtBeginningOfMainSubprogram = false,
        },
      }

      for _, lang in ipairs({ "c", "cpp" }) do
        dap.configurations[lang] = configs
      end
    end,
  },
}
