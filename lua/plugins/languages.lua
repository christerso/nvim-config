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
          -- New vim.lsp.config signature: (bufnr, on_dir) — must CALL on_dir(path),
          -- not return it. The old function(fname) form silently failed to attach.
          root_dir = function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            local root = vim.fs.root(fname, {
              "compile_commands.json",
              "compile_flags.txt",
              "Makefile",
              "configure.ac",
              "meson.build",
              "build.ninja",
              ".clangd",
              ".git",
            })
            on_dir(root or vim.fs.dirname(fname))
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
              -- Disabled: Neovim 0.12's semantic-tokens handler crashes on the
              -- token ranges gopls emits (semantic_tokens.lua:376 traceback on
              -- every edit). Treesitter handles Go highlighting. Flip back to
              -- true (and restore the force-enable in setup.gopls below) once
              -- the upstream handler is fixed.
              semanticTokens = false,
            },
          },
        },
      },
      setup = {
        gopls = function(_, _)
          -- Kill gopls semantic tokens client-side. Neovim 0.12's handler
          -- (runtime/lua/vim/lsp/semantic_tokens.lua:376) throws while
          -- processing gopls' range token responses, spamming a
          -- "vim.schedule callback" error on every edit. Nil-ing the
          -- provider on attach stops Neovim ever requesting them.
          --
          -- To re-enable later: set semanticTokens = true above and restore
          -- the old force-enable block (git history) here. If you want to keep
          -- semantic tokens but avoid the crash, try setting only `range =
          -- false` on the provider instead of nil-ing it — the traceback is in
          -- the textDocument/semanticTokens/range path specifically.
          Snacks.util.lsp.on({ name = "gopls" }, function(_, client)
            client.server_capabilities.semanticTokensProvider = nil
          end)
        end,
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
        -- Schema formats (Emacs equivalents live in lisp/lang-formats.el)
        "proto",
        "capnp",
        -- Fullstack-React web grammars (json/json5 also come via the lang.json
        -- extra; listed here so they're guaranteed even if that extra changes).
        "css",
        "scss",
        "html",
        "json",
        "json5",
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
        -- Fullstack-React web tooling. tailwindcss-language-server and json-lsp
        -- are installed by the lang.tailwind / lang.json extras; these three
        -- complete the set: CSS, HTML, and Emmet expansion (jsx/tsx aware).
        "css-lsp",
        "html-lsp",
        "emmet-language-server",
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

  -- golings keeps reference solutions tagged `//go:build ignore`. golangci-lint
  -- exits 7 ("build constraints exclude all Go files") when nvim-lint points it
  -- at a directory of such files, surfacing a useless warning. Skip the linter
  -- for any build-ignored Go buffer (LazyVim honours a per-linter `condition`).
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        golangcilint = {
          condition = function()
            for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, 15, false)) do
              if line:match("^//go:build%s+ignore%s*$") or line:match("^//%s*%+build%s+ignore%s*$") then
                return false -- build-ignored: golangci-lint can't typecheck it
              end
              if line:match("^package%s") then
                break -- build tags must precede `package`; stop scanning
              end
            end
            return true
          end,
        },
      },
    },
  },

  -- NOTE: JS/TS/React ESLint is now handled by the
  -- `lazyvim.plugins.extras.linting.eslint` extra (eslint-lsp) enabled in
  -- lazyvim.json. It gives real LSP diagnostics + `EslintFixAll` on save and
  -- understands flat config (eslint.config.js / .mjs). The old nvim-lint
  -- CLI-based eslint entries were removed so diagnostics aren't reported twice.
  -- Add non-eslint linters here if you ever need them.

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
