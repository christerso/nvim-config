-- x86-64 assembly support (NASM + GAS) — mirrors ~/.emacs.d/lisp/lang-asm.el
--
-- Toolchain:
--   nasm:    ~/.local/bin/nasm           (Intel syntax, *.asm/*.nasm)
--   as/ld:   binutils                    (AT&T syntax, *.s/*.S — gcc -S output)
--   asm-lsp: /usr/bin/asm-lsp            (AUR `asm-lsp`)
--
-- asm-lsp (https://github.com/bergercookie/asm-lsp) provides hover docs for
-- every instruction and register — ideal while learning — plus completion and
-- label navigation. Global config: ~/.config/asm-lsp/.asm-lsp.toml
-- (x86-64 / nasm; per-project .asm-lsp.toml overrides it).

return {
  -- Filetypes: NASM sources get ft=nasm (better highlighting + correct LSP
  -- dialect); plain .s/.S stay ft=asm (GAS).
  {
    "neovim/nvim-lspconfig",
    -- NOTE: g:asmsyntax = "nasm" (the knob that makes .asm files ft=nasm)
    -- lives in lua/config/options.lua — a plugin-spec `init` here gets
    -- clobbered when lazy.nvim merges the other nvim-lspconfig fragments.
    opts = {
      servers = {
        asm_lsp = {
          mason = false, -- installed system-wide from the AUR
          cmd = { "asm-lsp" },
          filetypes = { "asm", "nasm" },
          root_dir = function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            on_dir(vim.fs.root(fname, { ".asm-lsp.toml", ".git" }) or vim.fs.dirname(fname))
          end,
          keys = {
            -- Assemble + link + run the current file: nasm for ft=nasm, as for ft=asm.
            {
              "<leader>cr",
              function()
                local file = vim.fn.expand("%:t")
                local base = vim.fn.expand("%:t:r")
                local cmd
                if vim.bo.filetype == "nasm" then
                  cmd = string.format("nasm -f elf64 -g -F dwarf %s -o %s.o && ld %s.o -o %s && ./%s", file, base, base, base, base)
                else
                  cmd = string.format("as -g %s -o %s.o && ld %s.o -o %s && ./%s", file, base, base, base, base)
                end
                vim.cmd("write")
                vim.cmd("split | terminal " .. cmd)
              end,
              desc = "Assemble, link & run (x86-64)",
            },
          },
        },
      },
    },
  },

  -- Treesitter grammars for both dialects.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "asm", "nasm" })
    end,
  },
}
