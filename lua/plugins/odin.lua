-- Odin support for LazyVim
--
-- Toolchain:
--   odin: ~/.local/bin/odin → ~/.local/opt/odin/odin  (installed by hand)
--   ols:  /usr/bin/ols                                (Arch package `ols`)
--
-- ols is the Odin Language Server (https://github.com/DanielGavin/ols).
-- It's packaged in `extra/ols` on Arch, so Mason does not need to manage it.
-- nvim-lspconfig already ships an `ols` server definition; we just configure
-- it here.

return {
  -- ─────────────────────────────────────────────────────────────────────
  -- LSP: ols
  -- ─────────────────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ols = {
          mason = false,
          cmd = { "ols" },
          filetypes = { "odin" },
          keys = {
            { "<leader>cb", "<cmd>!odin build .<cr>",        desc = "odin build ." },
            { "<leader>cr", "<cmd>!odin run .<cr>",          desc = "odin run ." },
            { "<leader>tt", "<cmd>!odin test .<cr>",         desc = "odin test ." },
            { "<leader>tf", "<cmd>!odin test %<cr>",         desc = "odin test (current file)" },
            { "<leader>cc", "<cmd>!odin check .<cr>",        desc = "odin check ." },
            { "<leader>cv", "<cmd>!odin version<cr>",        desc = "odin version" },
          },
          -- ols reads its config from `ols.json` at project root, but most
          -- options can also be sent via initializationOptions. See
          -- https://github.com/DanielGavin/ols/blob/master/docs/configuration.md
          init_options = {
            checker_args = "-vet -strict-style",
            enable_semantic_tokens = true,
            enable_document_symbols = true,
            enable_hover = true,
            enable_snippets = true,
            enable_format = true,
            enable_inlay_hints = true,
            enable_procedure_snippet = true,
            enable_procedure_context = true,
            enable_references = true,
            enable_rename = true,
            enable_label_details = true,
          },
        },
      },
    },
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- Treesitter — `odin` parser ships with nvim-treesitter.
  -- ─────────────────────────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "odin" })
    end,
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- Filetype — *.odin → odin (LazyVim's filetype.lua already does this,
  -- declared here for safety against future regressions).
  -- ─────────────────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.filetype.add({
        extension = {
          odin = "odin",
        },
      })
    end,
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- Conform — odinfmt comes with ols (LSP-side formatter), so we delegate
  -- formatting to the language server. No external `odinfmt` binary.
  -- ─────────────────────────────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        odin = { lsp_format = "fallback" },
      },
    },
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- DAP — Odin compiles to native, so codelldb (already provided by the
  -- Rust / C extras) debugs Odin executables fine.
  -- ─────────────────────────────────────────────────────────────────────
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
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
      dap.configurations.odin = dap.configurations.odin
        or {
          {
            name = "Launch Odin executable",
            type = "codelldb",
            request = "launch",
            program = function()
              return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            args = {},
          },
        }
    end,
  },
}
