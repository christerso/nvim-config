#!/bin/bash
# Neovim Dependencies Installation Script for Arch Linux
# Run with: chmod +x install-deps.sh && ./install-deps.sh

set -e

echo "============================================"
echo "Neovim Dependencies Installation"
echo "============================================"
echo ""

# Check if we're on Arch-based system
if ! command -v pacman &> /dev/null; then
    echo "⚠️  This script is for Arch Linux. Please install dependencies manually."
    exit 1
fi

# Tree-sitter CLI
echo "📦 Installing tree-sitter-cli..."
if command -v npm &> /dev/null; then
    npm install -g tree-sitter-cli
    echo "✅ tree-sitter-cli installed"
else
    echo "❌ npm not found. Please install Node.js first."
    exit 1
fi

# Node.js neovim module (for Copilot)
echo ""
echo "📦 Installing neovim npm package (for Copilot)..."
npm install -g neovim
echo "✅ neovim npm package installed"

# LazyGit
echo ""
echo "📦 Installing lazygit..."
if sudo pacman -S --noconfirm lazygit; then
    echo "✅ lazygit installed"
else
    echo "⚠️  lazygit installation failed (optional - you can skip)"
fi

# Zathura and xdotool (for LaTeX)
echo ""
echo "📦 Installing Zathura PDF viewer and xdotool..."
sudo pacman -S --noconfirm zathura zathura-pdf-poppler xdotool
echo "✅ Zathura and xdotool installed"

# Ask about TeX Live
echo ""
echo "============================================"
echo "LaTeX/TeX Live Installation"
echo "============================================"
echo ""
echo "For LaTeX support, you need TeX Live."
echo ""
echo "Options:"
echo "  1) Quick install (texlive-basic) - Fast but limited"
echo "  2) Skip for now (install full TeX Live manually later)"
echo "  3) Exit and install full TeX Live manually now"
echo ""
read -p "Choose [1/2/3]: " tex_choice

case $tex_choice in
    1)
        echo ""
        echo "📦 Installing basic TeXLive..."
        sudo pacman -S --noconfirm texlive-basic texlive-bin biber
        echo "✅ Basic TeX Live installed"
        echo "⚠️  For complete LaTeX support, install full TeX Live later"
        echo "   See SETUP_INSTRUCTIONS.md for details"
        ;;
    2)
        echo "⏭️  Skipping TeX Live installation"
        ;;
    3)
        echo ""
        echo "To install full TeX Live manually:"
        echo ""
        echo "  cd /tmp"
        echo "  wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"
        echo "  tar -xzf install-tl-unx.tar.gz"
        echo "  cd install-tl-*"
        echo "  sudo ./install-tl"
        echo ""
        echo "After installation, add to PATH:"
        echo "  echo 'export PATH=/usr/local/texlive/2024/bin/x86_64-linux:\$PATH' >> ~/.bashrc"
        echo ""
        exit 0
        ;;
esac

# Python neovim module (optional)
echo ""
echo "📦 Installing Python neovim module (optional)..."
if command -v python3 &> /dev/null; then
    python3 -m pip install --user --upgrade pynvim
    echo "✅ Python neovim module installed"
else
    echo "⚠️  Python not found. Skipping (optional anyway)"
fi

echo ""
echo "============================================"
echo "✅ Installation Complete!"
echo "============================================"
echo ""
echo "Installed:"
echo "  ✅ tree-sitter-cli"
echo "  ✅ neovim npm package"
echo "  ✅ lazygit"
echo "  ✅ zathura + xdotool"
if [ "$tex_choice" = "1" ]; then
    echo "  ✅ basic TeX Live"
fi
echo "  ✅ Python neovim module"
echo ""
echo "Next steps:"
echo "  1. Start Neovim: nvim"
echo "  2. Wait for plugins to install (first time)"
echo "  3. Authenticate Copilot: :Copilot auth"
echo "  4. Check health: :checkhealth"
echo ""

if [ "$tex_choice" = "1" ]; then
    echo "⚠️  Note: You installed basic TeX Live"
    echo "   For complete LaTeX features, consider installing full TeX Live"
    echo "   See SETUP_INSTRUCTIONS.md for instructions"
    echo ""
fi

echo "🚀 You're ready to go! Happy coding!"
