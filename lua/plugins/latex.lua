-- LaTeX support with VimTeX for full editing, compilation, and preview capabilities
-- IMPORTANT: Requires TeX Live installation
-- Install from: https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
-- After downloading:
-- tar -xzf install-tl-unx.tar.gz
-- cd install-tl-*
-- sudo ./install-tl
-- Follow the interactive installer and add TeX Live bin directory to PATH

return {
  -- VimTeX - A modern Vim and Neovim filetype plugin for LaTeX files
  {
    "lervag/vimtex",
    lazy = false, -- lazy-loading will disable inverse search
    ft = { "tex", "bib" },
    config = function()
      -- VimTeX configuration
      vim.g.vimtex_view_method = "zathura" -- or 'skim' on macOS, 'evince', 'okular'
      vim.g.vimtex_view_general_viewer = "zathura"

      -- Compiler settings
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        build_dir = "",
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        hooks = {},
        options = {
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }

      -- TOC settings
      vim.g.vimtex_toc_config = {
        name = "TOC",
        layers = { "content", "todo", "include" },
        split_width = 30,
        todo_sorted = 0,
        show_help = 1,
        show_numbers = 1,
      }

      -- Quickfix settings
      vim.g.vimtex_quickfix_mode = 0 -- Don't open quickfix automatically
      vim.g.vimtex_quickfix_open_on_warning = 0

      -- Fold settings
      vim.g.vimtex_fold_enabled = 1
      vim.g.vimtex_fold_manual = 0
      vim.g.vimtex_fold_types = {
        markers = { enabled = 1 },
        sections = { enabled = 1 },
        envs = {
          enabled = 1,
          whitelist = { "figure", "table", "equation", "align" },
        },
      }

      -- Syntax highlighting
      vim.g.vimtex_syntax_enabled = 1
      vim.g.vimtex_syntax_conceal_disable = 0

      -- Indentation
      vim.g.vimtex_indent_enabled = 1
      vim.g.vimtex_indent_bib_enabled = 1

      -- Completion
      vim.g.vimtex_complete_enabled = 1
      vim.g.vimtex_complete_close_braces = 1
      vim.g.vimtex_complete_recursive_bib = 1

      -- Forward search (from Neovim to PDF)
      vim.g.vimtex_view_forward_search_on_start = 0

      -- Ignore mappings
      vim.g.vimtex_mappings_enabled = 1
      vim.g.vimtex_imaps_enabled = 1

      -- Error suppression
      vim.g.vimtex_log_ignore = {
        "Underfull",
        "Overfull",
        "specifier changed to",
        "Token not allowed in a PDF string",
      }

      -- Syntax concealment for a cleaner view
      vim.g.vimtex_syntax_conceal = {
        accents = 1,
        ligatures = 1,
        cites = 1,
        fancy = 1,
        spacing = 0,
        greek = 1,
        math_bounds = 0,
        math_delimiters = 1,
        math_fracs = 1,
        math_super_sub = 1,
        math_symbols = 1,
        sections = 0,
        styles = 1,
      }
    end,
  },

  -- LaTeX LSP support
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        texlab = {
          keys = {
            { "<leader>lb", "<cmd>TexlabBuild<cr>", desc = "Build LaTeX" },
            { "<leader>lf", "<cmd>TexlabForward<cr>", desc = "Forward search" },
          },
          settings = {
            texlab = {
              auxDirectory = ".",
              bibtexFormatter = "texlab",
              build = {
                args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
                executable = "latexmk",
                forwardSearchAfter = false,
                onSave = false,
              },
              chktex = {
                onEdit = false,
                onOpenAndSave = false,
              },
              diagnosticsDelay = 300,
              formatterLineLength = 80,
              forwardSearch = {
                args = { "--synctex-forward", "%l:1:%f", "%p" },
                executable = "zathura",
              },
              latexFormatter = "latexindent",
              latexindent = {
                modifyLineBreaks = false,
              },
            },
          },
        },
      },
    },
  },

  -- Mason: ensure LaTeX tools are installed
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "texlab",
        "latexindent",
      })
    end,
  },

  -- Treesitter support for LaTeX
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "latex", "bibtex" })
      end
    end,
  },

  -- Conform: LaTeX formatter
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        tex = { "latexindent" },
        bib = { "bibtex-tidy" },
      },
    },
  },

  -- Better LaTeX snippet support
  {
    "L3MON4D3/LuaSnip",
    optional = true,
    dependencies = {
      {
        "evesdropper/luasnip-latex-snippets.nvim",
        config = function()
          require("luasnip-latex-snippets").setup({
            use_treesitter = true,
          })
        end,
      },
    },
    opts = function(_, opts)
      opts.enable_autosnippets = true
      return opts
    end,
  },

  -- Optional: nabla.nvim for rendering LaTeX equations in the buffer
  {
    "jbyuki/nabla.nvim",
    ft = { "tex", "markdown" },
    keys = {
      {
        "<leader>lp",
        function()
          require("nabla").popup()
        end,
        desc = "Preview LaTeX equation",
      },
      {
        "<leader>le",
        function()
          require("nabla").enable_virt()
        end,
        desc = "Enable virtual LaTeX",
      },
      {
        "<leader>ld",
        function()
          require("nabla").disable_virt()
        end,
        desc = "Disable virtual LaTeX",
      },
    },
  },

  -- cmp source for vimtex
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "micangl/cmp-vimtex",
    },
    opts = function(_, opts)
      table.insert(opts.sources, { name = "vimtex" })
    end,
  },
}
