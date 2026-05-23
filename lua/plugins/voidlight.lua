return {
  {
    "christerso/voidlight-lazyvim-theme",
    name = "voidlight",
    lazy = false,
    priority = 1000,
    config = function()
      require("voidlight").setup()
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "voidlight",
    },
  },
}
