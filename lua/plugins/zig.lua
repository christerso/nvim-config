-- Zig support for LazyVim
--
-- Toolchain:
--   zig:  ~/.local/bin/zig  → ~/.local/opt/zig/zig          (0.16.0)
--   zls:  ~/.local/bin/zls  → ~/.local/opt/zls/zls          (0.16.0, version-matched)
--
-- Both are installed by hand outside Mason, mirroring how rust-analyzer
-- comes from rustup in languages.lua — keeps version pinned to the Zig
-- compiler and avoids Mason fighting an external install.

return {
  -- ─────────────────────────────────────────────────────────────────────
  -- LSP: zls
  -- ─────────────────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        zls = {
          -- Tell mason-lspconfig not to install/manage this server.
          mason = false,
          cmd = { "zls" },
          filetypes = { "zig", "zir" },
          keys = {
            -- Build / run / test — buffer-local, attach only when zls is on.
            { "<leader>cb", "<cmd>!zig build<cr>",                                desc = "zig build" },
            { "<leader>cB", "<cmd>!zig build -Doptimize=ReleaseSafe<cr>",          desc = "zig build (ReleaseSafe)" },
            { "<leader>cr", "<cmd>!zig build run<cr>",                            desc = "zig build run" },
            { "<leader>tt", "<cmd>!zig build test<cr>",                           desc = "zig build test" },
            { "<leader>tf", "<cmd>!zig test %<cr>",                               desc = "zig test (current file)" },
            { "<leader>cZ", function() vim.lsp.buf.format({ async = false }) end, desc = "zig fmt (LSP)" },
            { "<leader>cv", "<cmd>!zig version<cr>",                              desc = "zig version" },
            -- ZLS-only code actions
            { "<leader>cu", "<cmd>lua vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } } })<cr>", desc = "Organize / discard unused (Zig)" },
          },
          -- ZLS configuration is sent via initializationOptions; see
          -- https://github.com/zigtools/zls/blob/master/schema.json
          settings = {
            zls = {
              -- Build-on-save runs `zig build check` after every save and
              -- surfaces compile errors as LSP diagnostics. Requires a
              -- `check` step in build.zig (idiomatic since Zig 0.13).
              enable_build_on_save = true,
              build_on_save_step = "check",

              -- Quality-of-life
              enable_snippets = true,
              enable_argument_placeholders = true,
              enable_autofix = false, -- let Conform/format-on-save handle it
              warn_style = true,
              highlight_global_var_declarations = true,
              skip_std_references = false,
              prefer_ast_check_as_child_process = true,

              -- Inlay hints — drawn only when toggled on via <leader>uh
              inlay_hints_show_variable_type_hints = true,
              inlay_hints_show_parameter_name = true,
              inlay_hints_show_builtin = true,
              inlay_hints_exclude_single_argument = true,
              inlay_hints_hide_redundant_param_names = true,
              inlay_hints_hide_redundant_param_names_last_token = true,
            },
          },
        },
      },
    },
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- Treesitter
  -- ─────────────────────────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "zig" })
    end,
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- Conform — `zigfmt` runs `zig fmt --stdin`, falls back to ZLS formatting.
  -- ─────────────────────────────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        zig = { "zigfmt", lsp_format = "fallback" },
      },
    },
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- DAP — debug Zig executables via the same codelldb that ships with the
  -- Rust / C++ extras. No extra Mason package needed.
  -- ─────────────────────────────────────────────────────────────────────
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      -- codelldb adapter is registered by rustaceanvim / lazyvim.lang.rust;
      -- if it isn't (e.g. lang.rust extra disabled), register it ourselves.
      if not dap.adapters.codelldb then
        dap.adapters.codelldb = {
          type = "server",
          port = "${port}",
          executable = {
            command = vim.fn.exepath("codelldb"),
            args = { "--port", "${port}" },
          },
        }
      end
      dap.configurations.zig = dap.configurations.zig
        or {
          {
            name = "Launch zig-out binary",
            type = "codelldb",
            request = "launch",
            program = function()
              return vim.fn.input(
                "Executable: ",
                vim.fn.getcwd() .. "/zig-out/bin/",
                "file"
              )
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            args = {},
          },
          {
            name = "Launch test binary",
            type = "codelldb",
            request = "launch",
            program = function()
              return vim.fn.input(
                "Test exe: ",
                vim.fn.getcwd() .. "/zig-cache/o/",
                "file"
              )
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            args = {},
          },
        }
    end,
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- Filetype: pick zig for *.zig and *.zon (build manifests / Zig Object
  -- Notation). LazyVim ships filetype.lua-based detection, this just
  -- guarantees zon → zig grammar/LSP.
  -- ─────────────────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.filetype.add({
        extension = {
          zig = "zig",
          zon = "zig",
        },
      })
    end,
  },
}
