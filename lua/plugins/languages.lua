-- Language support configuration for LazyVim
--
-- Rust is handled by the lazyvim.plugins.extras.lang.rust extra (see lazyvim.json),
-- which brings in:
--   • mrcjkb/rustaceanvim   (replaces the deprecated simrat39/rust-tools.nvim)
--   • Saecki/crates.nvim    (Cargo.toml completion / version hints)
--   • treesitter rust + ron
--   • mason codelldb wiring for DAP
--
-- This file only customises rust-analyzer settings on top of that extra; it
-- does NOT register rust_analyzer with nvim-lspconfig directly — rustaceanvim
-- owns that and will fight any other setup.

return {
  -- ─────────────────────────────────────────────────────────────────────
  -- Inlay hints off by default — toggle with <leader>uh
  -- ─────────────────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    opts = { inlay_hints = { enabled = false } },
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- C/C++
  -- ─────────────────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          keys = {
            { "<leader>cR", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
          },
          root_dir = function(fname)
            if not fname or type(fname) ~= "string" or fname == "" then
              return nil
            end
            local util = require("lspconfig.util")
            return util.root_pattern(
              "Makefile",
              "configure.ac",
              "configure.in",
              "config.h.in",
              "meson.build",
              "meson_options.txt",
              "build.ninja"
            )(fname)
              or util.root_pattern("compile_commands.json", "compile_flags.txt")(fname)
              or vim.fs.root(fname, ".git")
          end,
          capabilities = { offsetEncoding = { "utf-16" } },
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
      },
      setup = {
        clangd = function(_, opts)
          local clangd_ext_opts = require("lazyvim.util").opts("clangd_extensions.nvim")
          require("clangd_extensions").setup(
            vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts })
          )
          return false
        end,
      },
    },
  },

  -- Clangd extensions for better C/C++ support
  {
    "p00f/clangd_extensions.nvim",
    lazy = true,
    config = function() end,
    opts = {
      inlay_hints = { inline = false },
      ast = {
        role_icons = {
          type = "",
          declaration = "",
          expression = "",
          specifier = "",
          statement = "",
          ["template argument"] = "",
        },
        kind_icons = {
          Compound = "",
          Recovery = "",
          TranslationUnit = "",
          PackExpansion = "",
          TemplateTypeParm = "",
          TemplateTemplateParm = "",
          TemplateParamObject = "",
        },
      },
    },
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- Go
  -- ─────────────────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          keys = {
            {
              "<leader>td",
              function()
                local test_name = vim.fn.search("func Test", "bcnW")
                if test_name > 0 then
                  local line = vim.fn.getline(test_name)
                  local name = line:match("func (Test%w+)")
                  if name then
                    vim.cmd("!go test -run " .. name)
                  end
                end
              end,
              desc = "Run test under cursor (Go)",
            },
            { "<leader>tf", "<cmd>!go test %<cr>", desc = "Run tests in file (Go)" },
            { "<leader>cb", "<cmd>make -C %:h<cr>", desc = "go build (binary next to file)" },
            { "<leader>cB", "<cmd>make ./...<cr>", desc = "go build ./... (verify only, no binary)" },
          },
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
              semanticTokens = true,
            },
          },
        },
      },
    },
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- Rust — extends the LazyVim lang.rust extra
  -- ─────────────────────────────────────────────────────────────────────
  {
    "mrcjkb/rustaceanvim",
    -- The LazyVim extra lazy-loads on `ft = "rust"`, which keeps
    -- :checkhealth rustaceanvim from finding the plugin until a .rs file is
    -- open. rustaceanvim's own docs recommend `lazy = false`; do that here.
    lazy = false,
    ft = nil,
    opts = function(_, opts)
      opts = opts or {}
      opts.server = opts.server or {}
      opts.server.default_settings = vim.tbl_deep_extend("force", opts.server.default_settings or {}, {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true,
            loadOutDirsFromCheck = true,
            buildScripts = { enable = true },
          },
          -- New shape: checkOnSave is a boolean; the command lives under `check`.
          checkOnSave = true,
          check = {
            command = "clippy",
            extraArgs = { "--no-deps" },
            allTargets = true,
          },
          procMacro = {
            enable = true,
            ignored = {
              ["async-trait"] = { "async_trait" },
              ["napi-derive"] = { "napi" },
              ["async-recursion"] = { "async_recursion" },
            },
          },
          inlayHints = {
            bindingModeHints = { enable = false },
            chainingHints = { enable = true },
            closingBraceHints = { enable = true, minLines = 25 },
            closureReturnTypeHints = { enable = "never" },
            lifetimeElisionHints = { enable = "never", useParameterNames = false },
            maxLength = 25,
            parameterHints = { enable = true },
            reborrowHints = { enable = "never" },
            renderColons = true,
            typeHints = { enable = true, hideClosureInitialization = false, hideNamedConstructor = false },
          },
          diagnostics = {
            experimental = { enable = true },
          },
          files = {
            excludeDirs = { ".direnv", ".git", ".github", ".gitlab", "bin", "node_modules", "target", "venv", ".venv" },
          },
        },
      })

      -- Make sure DAP autoloading stays on (default) and codelldb is preferred.
      opts.dap = opts.dap or {}
      return opts
    end,
  },

  -- Cargo.toml: crates.nvim is brought by the rust extra; we just extend it.
  {
    "Saecki/crates.nvim",
    opts = {
      completion = {
        cmp = { enabled = true },
        crates = { enabled = true },
      },
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- TypeScript / JavaScript
  -- ─────────────────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ts_ls = {
          enabled = true,
          keys = {
            {
              "<leader>co",
              function()
                vim.lsp.buf.code_action({
                  apply = true,
                  context = { only = { "source.organizeImports" }, diagnostics = {} },
                })
              end,
              desc = "Organize Imports",
            },
            {
              "<leader>cU",
              function()
                vim.lsp.buf.code_action({
                  apply = true,
                  context = { only = { "source.removeUnused" }, diagnostics = {} },
                })
              end,
              desc = "Remove Unused Imports (TS)",
            },
          },
          settings = {
            typescript = {
              format = {
                indentSize = vim.o.shiftwidth,
                convertTabsToSpaces = vim.o.expandtab,
                tabSize = vim.o.tabstop,
              },
            },
            javascript = {
              format = {
                indentSize = vim.o.shiftwidth,
                convertTabsToSpaces = vim.o.expandtab,
                tabSize = vim.o.tabstop,
              },
            },
            completions = { completeFunctionCalls = true },
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
      vim.list_extend(opts.ensure_installed, {
        "c",
        "cpp",
        "go",
        "gomod",
        "gowork",
        "gosum",
        -- "rust" and "ron" come from the lang.rust extra
        "javascript",
        "typescript",
        "tsx",
        "jsdoc",
        "toml",
      })
    end,
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- Mason — non-Rust tooling only.
  -- rust-analyzer and rustfmt come from rustup (/usr/lib/rustup/bin),
  -- so we don't ask Mason to install duplicates.
  -- ─────────────────────────────────────────────────────────────────────
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- C/C++
        "clangd",
        "clang-format",
        "codelldb",
        -- Go
        "gopls",
        "gofumpt",
        "goimports",
        "gomodifytags",
        "impl",
        "delve",
        -- JavaScript/TypeScript
        "typescript-language-server",
        "prettier",
        "eslint-lsp",
      },
    },
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- Conform / nvim-lint
  -- ─────────────────────────────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        c = { "clang_format" },
        cpp = { "clang_format" },
        go = { "goimports", "gofumpt" },
        rust = { "rustfmt", lsp_format = "fallback" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        toml = { "taplo" },
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        javascript = { "eslint" },
        typescript = { "eslint" },
        javascriptreact = { "eslint" },
        typescriptreact = { "eslint" },
      },
    },
  },

  -- DAP (Debug Adapter Protocol) — codelldb covers C/C++ and Rust.
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "jay-babu/mason-nvim-dap.nvim",
        opts = {
          ensure_installed = { "codelldb", "delve" },
        },
      },
    },
  },
}
