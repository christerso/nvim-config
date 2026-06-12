-- nacre.nvim — CivNode's color engine: 43 themes, text capped at pearl
-- (#f8f4ea) instead of white to cut eye strain. Inert until invoked:
-- voidlight stays the default colorscheme (see voidlight.lua).
--   Ctrl-8 / Ctrl-9  cycle themes      :NacrePick  fuzzy-pick one
--   :Nacre <name>    load by name      :NacreOff   back to voidlight
return {
  "christerso/nacre.nvim",
  cmd = { "Nacre", "NacreNext", "NacrePrev", "NacrePick", "NacreOff" },
  keys = {
    { "<C-8>", function() require("nacre").prev() end, mode = { "n", "i", "v" }, desc = "Previous nacre theme" },
    { "<C-9>", function() require("nacre").next() end, mode = { "n", "i", "v" }, desc = "Next nacre theme" },
  },
}
