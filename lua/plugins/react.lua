-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  Fullstack React support                                               ║
-- ╠══════════════════════════════════════════════════════════════════════╣
-- ║  This file adds the React/web pieces that are NOT already provided by   ║
-- ║  your manual TS setup (languages.lua) or the LazyVim extras enabled in  ║
-- ║  lazyvim.json. To recap who provides what:                              ║
-- ║                                                                         ║
-- ║   • TS/JS/JSX/TSX LSP ....... ts_ls            (languages.lua)          ║
-- ║   • Prettier formatting ..... conform          (languages.lua)          ║
-- ║   • ESLint (LSP + fix-save) .. extras.linting.eslint  (lazyvim.json)    ║
-- ║   • Tailwind CSS LSP ........ extras.lang.tailwind    (lazyvim.json)    ║
-- ║   • JSON LSP + SchemaStore ... extras.lang.json        (lazyvim.json)   ║
-- ║   • treesitter css/html/json . languages.lua                            ║
-- ║                                                                         ║
-- ║  THIS FILE adds: CSS/HTML/Emmet LSP servers, auto-closing JSX tags,     ║
-- ║  and a package.json companion (npm version hints, mirroring your        ║
-- ║  crates.nvim setup for Rust Cargo.toml).                                ║
-- ╚══════════════════════════════════════════════════════════════════════╝

return {
  -- ─────────────────────────────────────────────────────────────────────
  -- CSS, HTML and Emmet language servers.
  -- emmet_language_server expands abbreviations (e.g. `div.card>p` + <Tab>)
  -- and is wired for JSX/TSX, not just plain HTML.
  -- ─────────────────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        cssls = {},
        html = {},
        emmet_language_server = {
          filetypes = {
            "html",
            "css",
            "scss",
            "less",
            "sass",
            "javascriptreact",
            "typescriptreact",
            "javascript",
            "typescript",
            "vue",
            "svelte",
          },
        },
      },
    },
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- Auto close & auto rename JSX/HTML tags.
  -- Type <div> and it inserts </div>; rename the opening tag and the closing
  -- tag follows. This is the single biggest day-to-day quality-of-life win
  -- for editing JSX, and LazyVim does NOT ship it by default.
  -- ─────────────────────────────────────────────────────────────────────
  {
    "windwp/nvim-ts-autotag",
    event = "LazyFile",
    opts = {
      opts = {
        enable_close = true, -- auto close tags
        enable_rename = true, -- auto rename pairs
        enable_close_on_slash = false,
      },
    },
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- package.json companion — shows installed vs latest dependency versions
  -- inline, and gives actions to install/update/delete. This is the npm
  -- equivalent of the crates.nvim setup you already run for Rust.
  --   <leader>ns  toggle version display
  --   <leader>nu  update dependency on the line
  --   <leader>ni  install a new dependency
  --   <leader>nc  change the dependency version
  -- ─────────────────────────────────────────────────────────────────────
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    event = "BufRead package.json",
    opts = {
      package_manager = "npm",
      hide_up_to_date = false,
    },
    keys = {
      { "<leader>ns", function() require("package-info").toggle() end, desc = "Toggle package versions", ft = "json" },
      { "<leader>nu", function() require("package-info").update() end, desc = "Update package on line", ft = "json" },
      { "<leader>ni", function() require("package-info").install() end, desc = "Install new package", ft = "json" },
      { "<leader>nc", function() require("package-info").change_version() end, desc = "Change package version", ft = "json" },
    },
  },
}
