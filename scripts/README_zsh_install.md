# ZSH Environment Installation for macOS M3

## 📧 Email Instructions

This package contains everything needed to set up a professional zsh environment on macOS M3 (Apple Silicon).

## 📦 What's Included

- **install_zsh_macos.sh** - Automated installation script
- **README_zsh_install.md** - This instruction file

## 🚀 Quick Installation

### Step 1: Extract the Package

```bash
# Extract the compressed file
tar -xzf zsh_macos_install.tar.gz
cd zsh_macos_install
```

### Step 2: Run the Installation Script

```bash
# Make the script executable and run it
chmod +x install_zsh_macos.sh
./install_zsh_macos.sh
```

### Step 3: Restart Terminal

After the script completes, restart your terminal or run:

```bash
exec zsh
```

## 🎨 What Gets Installed

✅ **Homebrew** - Package manager for macOS
✅ **zsh** - Advanced shell
✅ **Oh My Zsh** - Framework for managing zsh configuration
✅ **Powerlevel10k** - Beautiful and functional theme
✅ **eza** - Modern ls replacement with colors and icons
✅ **zsh-completions** - Additional completion definitions
✅ **zsh-autosuggestions** - Fish-like autosuggestions
✅ **zsh-syntax-highlighting** - Syntax highlighting for zsh

## 🔧 Features You'll Get

- **Smart aliases**: `ls`, `ll`, `la`, `lt` (using eza)
- **Git integration**: Enhanced git commands and status
- **Auto-completion**: Intelligent command completion
- **Syntax highlighting**: Commands highlighted as you type
- **Beautiful prompt**: Powerlevel10k with git status, time, etc.

## ⚠️ Important Notes

- **Backup**: The script automatically backs up your existing `.zshrc`
- **Apple Silicon**: Optimized for M1/M2/M3 Macs
- **Safe**: Script checks for existing installations and skips if found
- **Non-destructive**: Won't overwrite existing configurations without backup

## 🆘 Troubleshooting

### If Homebrew installation fails

```bash
# Manual Homebrew installation
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### If zsh isn't set as default shell

```bash
# For Apple Silicon Macs
chsh -s /opt/homebrew/bin/zsh

# For Intel Macs
chsh -s /bin/zsh
```

### If you want to revert

```bash
# Restore your original .zshrc
cp ~/.zshrc.backup.* ~/.zshrc
```

## 📞 Support

If you encounter any issues, check:

1. You're running macOS (not Linux/Windows)
2. You have administrator privileges
3. Your internet connection is stable

## 🎉 Enjoy Your New Terminal

After installation, you'll have a professional, feature-rich terminal environment perfect for development and research work.
