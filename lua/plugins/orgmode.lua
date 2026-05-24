-- Orgmode configuration for note-taking and organization

return {
  {
    "nvim-orgmode/orgmode",
    event = "VeryLazy",
    ft = { "org" },
    config = function()
      -- Setup orgmode
      require("orgmode").setup({
        org_agenda_files = "~/orgfiles/**/*",
        org_default_notes_file = "~/orgfiles/refile.org",
        org_todo_keywords = { "TODO(t)", "INPROGRESS(i)", "WAITING(w)", "|", "DONE(d)", "CANCELLED(c)" },
        org_todo_keyword_faces = {
          TODO = ":foreground red :weight bold",
          INPROGRESS = ":foreground yellow :weight bold",
          WAITING = ":foreground orange :weight bold",
          DONE = ":foreground green :weight bold",
          CANCELLED = ":foreground gray :weight bold",
        },
        mappings = {
          org = {
            org_toggle_checkbox = "<C-Space>",
          },
        },
        org_startup_indented = true,
        org_adapt_indentation = true,
        org_hide_leading_stars = true,
        org_startup_folded = "showeverything",
        org_capture_templates = {
          t = { description = "Task", template = "* TODO %?\n  %u" },
          j = {
            description = "Journal",
            template = "* %U %?\n",
            target = "~/orgfiles/journal.org",
          },
        },
        win_split_mode = "auto",
        calendar_week_start_day = 1,
      })

      -- NOTE: If you are using nvim-treesitter with ~ensure_installed = "all"~ option
      -- add ~org~ to ignore_install
      -- require('nvim-treesitter.configs').setup({
      --   ensure_installed = 'all',
      --   ignore_install = { 'org' },
      -- })
    end,
  },

  -- Org bullets for better visual appearance
  {
    "akinsho/org-bullets.nvim",
    ft = "org",
    config = function()
      require("org-bullets").setup({
        concealcursor = false,
        symbols = {
          headlines = { "◉", "○", "✸", "✿" },
          checkboxes = {
            half = { "", "OrgTSCheckboxHalfChecked" },
            done = { "✓", "OrgDone" },
            todo = { "˟", "OrgTODO" },
          },
        },
      })
    end,
  },

  -- Treesitter grammar for org files
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if not opts.ensure_installed then
        opts.ensure_installed = {}
      end
      -- Don't add org to ensure_installed to avoid conflicts with orgmode parser
      if type(opts.ensure_installed) == "table" then
        -- Remove org if it exists
        for i, v in ipairs(opts.ensure_installed) do
          if v == "org" then
            table.remove(opts.ensure_installed, i)
            break
          end
        end
      end
    end,
  },

  -- Optional: headlines.nvim for better org-mode and markdown highlighting
  {
    "lukas-reineke/headlines.nvim",
    ft = { "org", "markdown" },
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("headlines").setup({
        org = {
          headline_highlights = { "Headline1", "Headline2", "Headline3", "Headline4", "Headline5", "Headline6" },
          codeblock_highlight = "CodeBlock",
          dash_highlight = "Dash",
          quote_highlight = "Quote",
        },
      })
    end,
  },
}
