-- GitHub Copilot configuration for AI-powered code completion

return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gR",
            open = "<M-CR>",
          },
          layout = {
            position = "bottom", -- | top | left | right
            ratio = 0.4,
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          hide_during_completion = true,
          debounce = 75,
          keymap = {
            -- accept is handled by blink.cmp's <Tab> via the ai_accept action
            -- below — NOT here. A copilot accept mapping is global and would
            -- lose to blink's buffer-local <Tab> anyway, so we disable it.
            accept = false,
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
        copilot_node_command = "node", -- Node.js version must be > 18.x
        server_opts_overrides = {},
      })

      -- Bridge copilot's inline ghost text to blink.cmp's <Tab>.
      -- LazyVim's blink <Tab> falls through snippet_forward -> ai_nes ->
      -- ai_accept -> literal tab. ai_accept is nil unless registered here
      -- (normally the LazyVim copilot *extra* does it; this config is
      -- hand-rolled, so we register it ourselves). With this set, pressing
      -- <Tab> while a copilot suggestion is visible accepts it; otherwise
      -- <Tab> behaves normally.
      LazyVim.cmp.actions.ai_accept = function()
        local suggestion = require("copilot.suggestion")
        if suggestion.is_visible() then
          LazyVim.create_undo() -- so a single <u> undoes the whole accept
          suggestion.accept()
          return true
        end
      end
    end,
  },

  -- Copilot chat for interactive AI assistance
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      debug = false,
      show_help = "yes",
      prompts = {
        Explain = "Explain how this code works.",
        Review = "Review this code and provide concise suggestions.",
        Tests = "Briefly explain how the selected code works, then generate unit tests.",
        Refactor = "Refactor this code to improve clarity and readability.",
      },
    },
    build = function()
      vim.notify("Please update the remote plugins by running ':UpdateRemotePlugins', then restart Neovim.")
    end,
    event = "VeryLazy",
    keys = {
      { "<leader>cce", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
      { "<leader>cct", "<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },
      { "<leader>ccr", "<cmd>CopilotChatReview<cr>", desc = "CopilotChat - Review code" },
      { "<leader>ccR", "<cmd>CopilotChatRefactor<cr>", desc = "CopilotChat - Refactor code" },
      { "<leader>ccn", "<cmd>CopilotChatReset<cr>", desc = "CopilotChat - Reset chat history" },
      { "<leader>ccq", function()
        local input = vim.fn.input("Quick Chat: ")
        if input ~= "" then
          require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
        end
      end, desc = "CopilotChat - Quick chat" },
    },
  },

  -- NOTE: there is intentionally no nvim-cmp / copilot-cmp integration here.
  -- This config uses blink.cmp (the LazyVim default); nvim-cmp is disabled and
  -- never loads, so a copilot-cmp source would be dead code. Copilot appears as
  -- inline ghost text, accepted via <Tab> through the ai_accept bridge above.
}
