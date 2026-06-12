# Complete Keybinding Reference

All custom keybindings configured in this LazyVim setup. Organized by category and checked for conflicts.

## ✅ Conflict Resolution

**Fixed Conflicts:**
- `<leader>cR` was used 3 times - Now assigned uniquely:
  - C/C++: `<leader>cR` - Switch Source/Header
  - Rust: `<leader>cA` - Code Action (changed from cR)
  - TypeScript: `<leader>cU` - Remove Unused Imports (changed from cR)
- `gr` in Copilot panel changed to `gR` (to avoid conflict with LSP "go to references")

---

## Standard LSP Keybindings (All Languages)

These work in C/C++, Go, Rust, JavaScript, TypeScript files:

| Key | Action | Description |
|-----|--------|-------------|
| `gd` | Go to Definition | Jump to symbol definition |
| `gr` | Go to References | Show all references |
| `gi` | Go to Implementation | Jump to implementation |
| `gt` | Go to Type Definition | Jump to type definition |
| `K` | Hover Documentation | Show documentation (overridden in Rust) |
| `<leader>ca` | Code Actions | Show available code actions |
| `<leader>cr` | Rename Symbol | Rename symbol under cursor |
| `<leader>cf` | Format Document | Format current file |
| `[d` | Previous Diagnostic | Go to previous diagnostic |
| `]d` | Next Diagnostic | Go to next diagnostic |
| `<leader>cd` | Line Diagnostics | Show diagnostics for current line |

---

## Language-Specific Keybindings

### C/C++ (Clangd)
| Key | Action |
|-----|--------|
| `<leader>cR` | Switch between Source/Header file |

### Go (gopls)
| Key | Action |
|-----|--------|
| `<leader>td` | Run test under cursor |
| `<leader>tf` | Run tests in current file |

### Rust (rust-analyzer)
| Key | Action |
|-----|--------|
| `K` | Hover Actions (Rust-specific hover) |
| `<leader>cA` | Code Action (Rust-specific) |
| `<leader>dr` | Run Debuggables |

### JavaScript/TypeScript (ts_ls)
| Key | Action |
|-----|--------|
| `<leader>co` | Organize Imports |
| `<leader>cU` | Remove Unused Imports |

### LaTeX (VimTeX & Texlab)
| Key | Action |
|-----|--------|
| `<leader>ll` | Compile LaTeX (VimTeX) |
| `<leader>lv` | View PDF (VimTeX) |
| `<leader>lc` | Clean auxiliary files (VimTeX) |
| `<leader>lt` | Toggle Table of Contents (VimTeX) |
| `<leader>lb` | Build LaTeX (Texlab) |
| `<leader>lf` | Forward search (sync to PDF) |
| `<leader>lp` | Preview LaTeX equation (nabla) |
| `<leader>le` | Enable virtual LaTeX rendering |
| `<leader>ld` | Disable virtual LaTeX rendering |

---

## GitHub Copilot

### Inline Suggestions (Insert Mode)
| Key | Action |
|-----|--------|
| `<M-l>` | Accept suggestion |
| `<M-]>` | Next suggestion |
| `<M-[>` | Previous suggestion |
| `<C-]>` | Dismiss suggestion |

### Copilot Panel
| Key | Action |
|-----|--------|
| `<M-CR>` | Open Copilot panel |
| `<CR>` | Accept suggestion (in panel) |
| `[[` | Jump to previous suggestion |
| `]]` | Jump to next suggestion |
| `gR` | Refresh suggestions |

### Copilot Chat
| Key | Action |
|-----|--------|
| `<leader>ccq` | Quick chat |
| `<leader>cce` | Explain code |
| `<leader>cct` | Generate tests |
| `<leader>ccr` | Review code |
| `<leader>ccR` | Refactor code |
| `<leader>ccn` | Reset chat history |

---

## Buffer Management

### Buffer Navigation
| Key | Action |
|-----|--------|
| `<S-h>` | Previous buffer |
| `<S-l>` | Next buffer |
| `[b` | Previous buffer (alternative) |
| `]b` | Next buffer (alternative) |
| `<leader><space>` | Quick buffer switch (fuzzy find) |
| `<leader>fb` | Browse buffers with preview |
| `<leader>bd` | Delete current buffer |
| `<leader>bo` | Delete other buffers |
| `<leader>br` | Delete buffers to the right |
| `<leader>bl` | Delete buffers to the left |
| `<leader>bp` | Pin/unpin buffer |
| `<leader>bP` | Delete all non-pinned buffers |

---

## File Navigation

### Telescope Fuzzy Finding
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Find Git files |
| `<leader>fr` | Recent files (frecency - smart sorting) |
| `<leader>fR` | Recent files (simple list) |
| `<leader>fF` | File browser |
| `-` | Open Oil file explorer (parent directory) |
| `<leader>-` | Open Oil in floating window |

### Neo-tree (Sidebar File Explorer)
| Key | Action |
|-----|--------|
| `<leader>e` | Toggle Neo-tree sidebar (root dir) |
| `<leader>E` | Toggle Neo-tree sidebar (cwd) |
| `<leader>fe` | Toggle Neo-tree sidebar (root dir) |
| `<leader>fE` | Toggle Neo-tree sidebar (cwd) |
| `<leader>ge` | Git status explorer |
| `<leader>be` | Buffer explorer |

Inside Neo-tree: `l`/`<CR>` open, `h` close node, `a` add, `d` delete, `r` rename, `Y` copy path, `P` toggle preview, `?` help.

### Search
| Key | Action |
|-----|--------|
| `<leader>sg` | Live grep (search in files) |
| `<leader>sw` | Search word under cursor |
| `<leader>ss` | Document symbols |
| `<leader>sS` | Workspace symbols |
| `<leader>sc` | Search commands |
| `<leader>:` | Command history |

---

## Oil.nvim (File Explorer)

When inside Oil buffer:

| Key | Action |
|-----|--------|
| `<CR>` | Open file/directory |
| `<C-s>` | Open in vertical split |
| `<C-h>` | Open in horizontal split |
| `<C-t>` | Open in new tab |
| `<C-p>` | Preview file |
| `<C-c>` | Close Oil |
| `<C-l>` | Refresh |
| `-` | Go to parent directory |
| `_` | Open current working directory |
| `g.` | Toggle hidden files |
| `g?` | Show help |
| `gs` | Change sort order |
| `gx` | Open with external program |

---

## UI Enhancements

### Noice (Better Messages)
| Key | Action |
|-----|--------|
| `<S-Enter>` | Redirect cmdline output (command mode) |
| `<leader>snl` | Show last message |
| `<leader>snh` | Show message history |
| `<leader>sna` | Show all messages |
| `<leader>snd` | Dismiss all notifications |

### Telescope (Inside Telescope)
| Key | Action |
|-----|--------|
| `<C-j>` | Move to next item |
| `<C-k>` | Move to previous item |
| `<C-n>` | Next in history |
| `<C-p>` | Previous in history |
| `<C-d>` | Delete buffer (in buffer picker) |
| `<C-u>` | Clear prompt |
| `q` | Close (normal mode) |

---

## Orgmode

| Key | Action |
|-----|--------|
| `<C-Space>` | Toggle checkbox |
| Standard org-mode bindings are available |

---

## Window & Tab Management (LazyVim Defaults)

| Key | Action |
|-----|--------|
| `<C-h>` | Move to left window |
| `<C-j>` | Move to down window |
| `<C-k>` | Move to up window |
| `<C-l>` | Move to right window |
| `<C-Up>` | Increase window height |
| `<C-Down>` | Decrease window height |
| `<C-Left>` | Decrease window width |
| `<C-Right>` | Increase window width |

---

## Git (LazyVim Defaults)

| Key | Action |
|-----|--------|
| `<leader>gg` | Open LazyGit |
| `<leader>gb` | Git blame line |
| `<leader>gB` | Git browse |
| `]h` | Next git hunk |
| `[h` | Previous git hunk |

---

## Terminal (LazyVim Defaults)

| Key | Action |
|-----|--------|
| `<C-/>` | Toggle terminal |
| `<C-_>` | Toggle terminal (alternative) |
| `<esc><esc>` | Exit terminal mode |

---

## Testing (Go-specific)

| Key | Action |
|-----|--------|
| `<leader>td` | Run test under cursor (Go) |
| `<leader>tf` | Run tests in file (Go) |

---

## Debugging

| Key | Action |
|-----|--------|
| `<leader>dr` | Run debuggables (Rust) |
| Standard DAP bindings available for C/C++, Go, Rust |

---

## Leader Key Groups (for reference)

| Prefix | Category |
|--------|----------|
| `<leader>b` | Buffer operations |
| `<leader>c` | Code operations (LSP) |
| `<leader>cc` | Copilot Chat |
| `<leader>d` | Debug operations |
| `<leader>f` | File/Find operations |
| `<leader>g` | Git operations |
| `<leader>l` | LaTeX operations |
| `<leader>s` | Search operations |
| `<leader>sn` | Noice (messages) |
| `<leader>t` | Test operations |

---

## Notes

1. **`<leader>` key**: In LazyVim, the default leader key is `<Space>`
2. **Alt/Meta key**: `<M-...>` means Alt+key (e.g., `<M-l>` = Alt+L)
3. **Shift key**: `<S-...>` means Shift+key (e.g., `<S-h>` = Shift+H)
4. **Control key**: `<C-...>` means Ctrl+key (e.g., `<C-p>` = Ctrl+P)

## Conflict-Free Guarantee

All keybindings have been carefully checked for conflicts. Each key combination is assigned to only one action in its respective context (mode/filetype).

## Quitting

| Key | Action | Description |
|-----|--------|-------------|
| `<C-q>` | Save all & quit | Writes every modified file-backed buffer, then force-quits Neovim — works from normal, insert, visual and terminal mode. No prompts. |
| `<leader>qq` | Quit all | LazyVim default (prompts on unsaved changes) |

## Assembly (x86-64 — ft=nasm for .asm/.nasm, ft=asm for .s/.S)

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>cr` | Assemble, link & run | `nasm -f elf64 … && ld && ./prog` (or `as`/`ld` for GAS files) in a split terminal |
| `K` | Instruction docs | asm-lsp hover documents every instruction/register |

asm-lsp global config: `~/.config/asm-lsp/.asm-lsp.toml` (NASM, x86-64); a project-local `.asm-lsp.toml` overrides it.

### Font Controls (Neovide only)
| Key | Action |
|-----|--------|
| `Ctrl+ScrollWheel` | Font size up / down |
| `Ctrl+=` / `Ctrl+-` | Font size up / down (keyboard) |
| `Ctrl+0` | Reset to default font and size |
| `Ctrl+1` … `Ctrl+5` | Switch font: JetBrains Mono / Fira Code / Cascadia Code / Hack / Meslo |

### Themes (nacre.nvim — voidlight stays the default)
| Key | Action |
|-----|--------|
| `Ctrl+8` / `Ctrl+9` | Previous / next nacre theme |
| `:NacrePick` | Pick a nacre theme from a list |
| `:NacreOff` | Back to voidlight |

### Sessions
Starting `nvim` or Neovide with no file arguments restores the last session
for that directory — buffers, splits, cursor position. `nvim somefile` still
opens just that file. See `lua/plugins/persistence.lua`.

### Wall Cheat Sheet
`cheatsheet/nvim-cheatsheet.pdf` — A4 landscape, black & white, built from
`nvim-cheatsheet.tex` with `lualatex` (TeX Live 2025).
