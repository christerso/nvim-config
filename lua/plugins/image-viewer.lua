-- Image viewer: open images in loupe (GNOME Image Viewer) instead of as a buffer.
-- Loupe auto-discovers sibling images in the directory — arrow keys navigate prev/next.

local image_exts = {
  png = true, jpg = true, jpeg = true, gif = true, bmp = true,
  tif = true, tiff = true, webp = true, svg = true, ico = true,
  avif = true, jxl = true,
}

local function open_image(filepath)
  filepath = vim.fn.resolve(vim.fn.fnamemodify(filepath, ":p"))
  vim.fn.jobstart({ "loupe", filepath }, { detach = true })
end

-- Intercept BufReadCmd for image files so they never load as a buffer.
vim.api.nvim_create_autocmd("BufReadCmd", {
  pattern = vim.tbl_map(function(ext)
    return "*." .. ext
  end, vim.tbl_keys(image_exts)),
  callback = function(ev)
    local bufnr = ev.buf
    local filepath = ev.file

    open_image(filepath)

    -- Close the empty buffer and go back
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(bufnr) then
        local alt = vim.fn.bufnr("#")
        if alt > 0 and alt ~= bufnr and vim.api.nvim_buf_is_valid(alt) then
          vim.api.nvim_set_current_buf(alt)
        else
          vim.cmd("enew")
        end
        pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
      end
    end)
  end,
})

return {}
