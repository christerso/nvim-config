-- Session restore: starting nvim/neovide with no file arguments drops you
-- exactly where you left off — same buffers, splits, tabs, cursor position —
-- the emacsclient feel. persistence.nvim (a LazyVim builtin) already saves
-- the session on every exit; this loads the current directory's session back
-- on a bare start. `nvim somefile` still opens just that file.
--
-- The VimEnter autocmd is registered from `init` because that runs during
-- startup, BEFORE VimEnter. config/autocmds.lua would be too late: LazyVim
-- loads it on VeryLazy, which fires after VimEnter.
return {
  "folke/persistence.nvim",
  init = function()
    vim.api.nvim_create_autocmd("StdinReadPre", {
      group = vim.api.nvim_create_augroup("restore_session_stdin", { clear = true }),
      callback = function()
        vim.g.started_with_stdin = true
      end,
    })

    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("restore_session", { clear = true }),
      nested = true, -- let restored buffers fire their own autocmds (ft, lsp, ...)
      callback = function()
        if vim.fn.argc(-1) == 0 and not vim.g.started_with_stdin then
          require("persistence").load()
          return
        end
        -- Neovide passes file args to nvim with `-p`, which here lands on an
        -- empty focused [No Name] buffer with the requested file parked in
        -- the bufferline (pre-existing quirk; happens with a stock config
        -- too). If we started with args but sit on an empty unnamed buffer,
        -- jump to the first real file buffer.
        vim.schedule(function()
          if vim.api.nvim_buf_get_name(0) ~= "" or vim.bo.modified then
            return
          end
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf) ~= "" then
              vim.api.nvim_set_current_buf(buf)
              return
            end
          end
        end)
      end,
    })
  end,
}
