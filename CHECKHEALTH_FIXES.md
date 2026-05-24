# Checkhealth Results and Fixes

Based on `:checkhealth` output, here are the issues and fixes:

---

## ✅ Fixed in Configuration

### 1. which-key deprecation warning ✅
**Issue:** `opts.defaults` is deprecated
**Fix Applied:** Updated to use `opts.spec` in `ui-enhancements.lua`

```lua
# Before:
opts = {
  defaults = {
    ["<leader>b"] = { name = "+buffer" },
    ...
  }
}

# After:
opts = {
  spec = {
    { "<leader>b", group = "buffer" },
    ...
  }
}
```

---

## 🔧 System Dependencies to Install

### Required for Full Functionality

#### 1. Tree-sitter CLI ❌ REQUIRED
```bash
npm install -g tree-sitter-cli
# OR
cargo install tree-sitter-cli
```

#### 2. LaTeX Tools (for VimTeX) ❌ REQUIRED if using LaTeX
```bash
# Install TeX Live (full installation from official source)
cd /tmp
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xzf install-tl-unx.tar.gz
cd install-tl-*
sudo ./install-tl

# Add to PATH (adjust year as needed)
echo 'export PATH=/usr/local/texlive/2024/bin/x86_64-linux:$PATH' >> ~/.bashrc
source ~/.bashrc

# OR quick install via package manager (less complete):
sudo pacman -S texlive-most texlive-bin biber
```

#### 3. Zathura PDF Viewer (for LaTeX preview) ❌ REQUIRED if using LaTeX
```bash
sudo pacman -S zathura zathura-pdf-poppler xdotool
```

#### 4. Node.js neovim module (for Copilot) ⚠️ REQUIRED if using Copilot
```bash
npm install -g neovim
```

#### 5. LazyGit (optional but recommended) ⚠️ OPTIONAL
```bash
sudo pacman -S lazygit
# OR
yay -S lazygit
```

---

## ⚠️ Optional Dependencies (Can be ignored)

### Python Provider (optional)
Only needed if using Python-based plugins:
```bash
python3 -m pip install --user --upgrade pynvim
```

### Ruby Provider (optional)
Only needed if using Ruby-based plugins:
```bash
gem install neovim
```

### Perl Provider (optional)
Only needed if using Perl-based plugins:
```bash
cpan install Neovim::Ext
```

### Luarocks (optional)
Only needed if plugins require it (none of ours do):
```bash
# Can be safely ignored - lazy.nvim will handle if needed
```

---

## 📋 Quick Install Script

Run this to install all required dependencies on Arch Linux:

```bash
#!/bin/bash

echo "Installing Neovim dependencies..."

# Tree-sitter CLI
echo "Installing tree-sitter-cli..."
npm install -g tree-sitter-cli

# Node.js neovim module (for Copilot)
echo "Installing neovim npm package..."
npm install -g neovim

# LazyGit
echo "Installing lazygit..."
sudo pacman -S --noconfirm lazygit

# Zathura and xdotool (for LaTeX)
echo "Installing Zathura..."
sudo pacman -S --noconfirm zathura zathura-pdf-poppler xdotool

# Basic TeX Live (for quick start - not complete)
echo "Installing basic TeXLive..."
sudo pacman -S --noconfirm texlive-basic texlive-bin biber

# Python neovim module (optional)
echo "Installing Python neovim module..."
python3 -m pip install --user --upgrade pynvim

echo ""
echo "✅ Basic dependencies installed!"
echo ""
echo "⚠️  For FULL LaTeX support, install complete TeX Live:"
echo "   See SETUP_INSTRUCTIONS.md for details"
echo ""
echo "🚀 You can now start Neovim: nvim"
```

Save as `install-deps.sh`, make executable with `chmod +x install-deps.sh`, and run `./install-deps.sh`

---

## 🎯 Priority Installation Order

### Must Install Now:
1. ✅ **tree-sitter-cli** - Required for treesitter parsers
2. ✅ **neovim npm package** - Required for Copilot

### Install if Using LaTeX:
3. ✅ **TeX Live** - Required for LaTeX compilation
4. ✅ **Zathura + xdotool** - Required for PDF preview

### Nice to Have:
5. ⚠️ **lazygit** - Better git integration
6. ⚠️ **Python neovim** - For Python-based plugins

---

## 📊 Checkhealth Summary

After installing dependencies, these sections should be clean:

| Component | Status | Action Required |
|-----------|--------|-----------------|
| lazy | ⚠️ 2 warnings | Can ignore luarocks warnings |
| lazyvim | ⚠️ 1 warning | Install lazygit (optional) |
| lazyvim treesitter | ❌ ERROR | **Install tree-sitter-cli** |
| snacks | ⚠️ warnings | Terminal/image features (optional) |
| vim.deprecated | ✅ OK | None |
| vim.health | ✅ OK | None |
| vim.lsp | ✅ OK | None |
| vim.provider | ⚠️ 6 warnings | Install npm/python neovim (optional) |
| vim.treesitter | ✅ OK | None |
| vimtex | ❌ 2 ERRORS | **Install TeX Live + Zathura** |

---

## ✅ Verification

After installing dependencies, verify with:

```vim
:checkhealth
```

Expected results:
- ✅ tree-sitter CLI installed
- ✅ neovim npm package installed
- ✅ LaTeX tools installed (if using LaTeX)
- ✅ No critical errors

---

## 🚀 Ready to Use

After running the installation script or manually installing dependencies:

1. Start Neovim: `nvim`
2. Wait for plugins to install (first time only)
3. Authenticate Copilot: `:Copilot auth`
4. Verify everything: `:checkhealth`

All configuration errors are fixed! Only system dependencies need installation.
