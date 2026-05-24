# 💤 LazyVim Configuration

Complete Neovim configuration with full language support for C/C++, Go, Rust, JavaScript/TypeScript, LaTeX, and Orgmode.

## 🚀 Quick Start

### 1. Install System Dependencies

```bash
cd ~/.config/nvim
./install-deps.sh
```

### 2. Start Neovim
```bash
nvim
```
First launch will automatically install all plugins (takes 2-3 minutes).

### 3. Setup Copilot
```vim
:Copilot auth
```

### 4. Verify Installation
```vim
:checkhealth
```

## 📚 Documentation

- [CHECKHEALTH_FIXES.md](CHECKHEALTH_FIXES.md) - System dependencies and fixes
- [KEYBINDINGS.md](KEYBINDINGS.md) - Complete keybinding reference (conflict-free!)
- [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md) - Detailed setup guide
- [VERIFICATION_REPORT.md](VERIFICATION_REPORT.md) - Testing results

## ✨ Features

**Language Support:** C/C++, Go, Rust, JavaScript/TypeScript, LaTeX, Orgmode
**Tools:** GitHub Copilot, Oil.nvim, Telescope, Bufferline, LazyGit

## ⌨️ Key Bindings

- `<leader><space>` - Quick buffer switch
- `<leader>ff` - Find files
- `-` - Oil file explorer
- `gd` - Go to definition
- `<M-l>` - Accept Copilot

See [KEYBINDINGS.md](KEYBINDINGS.md) for complete list.

## ✅ Status

All configuration issues fixed! Only system dependencies need installation.
Run `./install-deps.sh` to install automatically.
