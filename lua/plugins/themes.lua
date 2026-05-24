-- Dark-theme alternates that share voidlight's vibe:
-- low-contrast, warm accents, distraction-free.
-- Swap with `:colorscheme vague` / `melange` / `kanagawa-dragon`.
return {
  {
    "vague2k/vague.nvim",
    lazy = true,
    config = function()
      require("vague").setup({
        transparent = false,
        style = {
          boolean = "bold",
          number = "none",
          float = "none",
          error = "bold",
          comments = "italic",
          conditionals = "none",
          functions = "none",
          headings = "bold",
          operators = "none",
          strings = "italic",
          variables = "none",
          keywords = "none",
          types = "none",
        },
      })
    end,
  },

  {
    "savq/melange-nvim",
    lazy = true,
  },

  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    opts = {
      compile = false,
      undercurl = true,
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = false },
      statementStyle = { bold = false },
      typeStyle = {},
      transparent = false,
      dimInactive = false,
      terminalColors = true,
      theme = "dragon",
      background = {
        dark = "dragon",
        light = "lotus",
      },
    },
  },
}
