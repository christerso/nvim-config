# LazyVim Setup Instructions

## System Dependencies to Install

### 1. Node.js (Required for Copilot and TypeScript)
```bash
# Install Node.js 18+ (required for Copilot)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 2. Language Toolchains

#### C/C++
```bash
# clangd is typically included with clang
sudo apt-get install -y clang clang-format lldb
```

#### Go
```bash
# Download and install Go from official site
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc
```

#### Rust
```bash
# Install Rust via rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
```

### 3. LaTeX (TeX Live)

#### Option A: Full TeX Live Installation (Recommended)
```bash
# Download and install TeX Live
cd /tmp
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xzf install-tl-unx.tar.gz
cd install-tl-*
sudo ./install-tl

# After installation, add to PATH (adjust year as needed)
echo 'export PATH=/usr/local/texlive/2024/bin/x86_64-linux:$PATH' >> ~/.bashrc
source ~/.bashrc
```

#### Option B: Basic TeX Live (Faster but less complete)
```bash
sudo apt-get install -y texlive texlive-latex-extra texlive-science latexmk
```

### 4. PDF Viewer for LaTeX (Zathura)
```bash
sudo apt-get install -y zathura zathura-pdf-poppler
```

### 5. Additional Tools
```bash
# Ripgrep for better searching
sudo apt-get install -y ripgrep

# fd for better file finding
sudo apt-get install -y fd-find

# Git (if not already installed)
sudo apt-get install -y git
```

## First Time Setup in Neovim

1. **Open Neovim:**
   ```bash
   nvim
   ```

2. **LazyVim will automatically:**
   - Install all plugins
   - Install LSP servers via Mason
   - Install treesitter parsers
   - Set up formatters and linters

3. **Setup Copilot:**
   - Run `:Copilot auth` in Neovim
   - Follow the authentication flow in your browser
   - Enter the code when prompted

4. **Create Orgmode directory:**
   ```bash
   mkdir -p ~/orgfiles
   ```

## Key Features

### Language Support
- **C/C++**: Clangd with header/source switching (`<leader>cR`)
- **Go**: Full gopls support with test runners
- **Rust**: rust-analyzer with hover actions and debugging
- **JavaScript/TypeScript**: ts_ls with organize imports

### GitHub Copilot
- **Inline suggestions**: `<M-l>` to accept
- **Chat commands**: `<leader>cc` prefix
- **Quick chat**: `<leader>ccq`

### Oil.nvim File Explorer
- Press `-` to open parent directory
- Edit filesystem like a buffer
- Save to apply changes

### LaTeX Workflow
- Write `.tex` files
- `:VimtexCompile` or `<leader>ll` to compile
- `:VimtexView` or `<leader>lv` to view PDF
- Live preview with Zathura
- Equation preview with `<leader>lp`

### Orgmode
- Create `.org` files in `~/orgfiles/`
- Standard org-mode keybindings
- Agenda views and task management

## Common Commands

### Mason (Package Manager)
- `:Mason` - Open Mason UI to manage LSP servers and tools
- `:MasonUpdate` - Update all packages

### Lazy (Plugin Manager)
- `:Lazy` - Open Lazy UI
- `:Lazy update` - Update all plugins
- `:Lazy sync` - Install missing plugins and clean unused

### LSP
- `gd` - Go to definition
- `gr` - Go to references
- `gi` - Go to implementation
- `K` - Hover documentation
- `<leader>ca` - Code actions
- `<leader>cr` - Rename symbol
- `<leader>cf` - Format document

### Copilot
- `<M-l>` - Accept suggestion
- `<M-]>` - Next suggestion
- `<M-[>` - Previous suggestion
- `<C-]>` - Dismiss suggestion

## Troubleshooting

### LSP Not Working
1. Check Mason: `:Mason`
2. Ensure language server is installed
3. Restart Neovim: `:q` then reopen

### Copilot Not Working
1. Check Node.js version: `node --version` (must be 18+)
2. Authenticate: `:Copilot auth`
3. Check status: `:Copilot status`

### LaTeX Preview Not Working
1. Ensure Zathura is installed: `which zathura`
2. Check VimTeX: `:VimtexInfo`
3. Compile manually: `:VimtexCompile`

### Orgmode Not Loading
1. Create orgfiles directory: `mkdir -p ~/orgfiles`
2. Open a `.org` file: `nvim ~/orgfiles/test.org`
3. Check treesitter: `:TSInstall org` (if needed)

## Configuration Files Created

All configuration files are in `~/.config/nvim/lua/plugins/`:
- `languages.lua` - All language LSP configurations
- `copilot.lua` - GitHub Copilot setup
- `oil.lua` - Oil.nvim file explorer
- `orgmode.lua` - Orgmode configuration
- `latex.lua` - LaTeX/VimTeX setup

You can customize any of these files to suit your needs!
