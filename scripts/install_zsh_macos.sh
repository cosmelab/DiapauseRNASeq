#!/bin/bash

# Install zsh environment for macOS M3
# This script installs Homebrew, Oh My Zsh, plugins, theme, and eza

set -e  # Exit on any error

echo "🚀 Starting zsh environment setup for macOS M3..."

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is designed for macOS only"
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew is already installed"
fi

# Install zsh if not already installed
if ! command -v zsh &> /dev/null; then
    echo "📦 Installing zsh..."
    brew install zsh
else
    echo "✅ zsh is already installed"
fi

# Install eza (modern ls replacement)
echo "📦 Installing eza..."
brew install eza

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📦 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "✅ Oh My Zsh is already installed"
fi

# Install Powerlevel10k theme
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    echo "🎨 Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
else
    echo "✅ Powerlevel10k theme is already installed"
fi

# Install zsh plugins
echo "🔌 Installing zsh plugins..."

# zsh-completions
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-completions" ]; then
    git clone https://github.com/zsh-users/zsh-completions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions
else
    echo "✅ zsh-completions is already installed"
fi

# zsh-autosuggestions
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
else
    echo "✅ zsh-autosuggestions is already installed"
fi

# zsh-syntax-highlighting
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
else
    echo "✅ zsh-syntax-highlighting is already installed"
fi

# Configure .zshrc
echo "⚙️  Configuring .zshrc..."

# Backup existing .zshrc if it exists
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    echo "📋 Backed up existing .zshrc"
fi

# Create new .zshrc with our configuration
cat > "$HOME/.zshrc" << 'EOF'
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(git zsh-completions zsh-autosuggestions zsh-syntax-highlighting)

# Disable auto-update
export DISABLE_AUTO_UPDATE="true"
export DISABLE_UPDATE_PROMPT="true"

# Disable Powerlevel10k configuration wizard
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# eza aliases (modern ls replacement)
if command -v eza > /dev/null; then
  alias ls="eza"
  alias ll="eza -l"
  alias la="eza -la"
  alias lt="eza --tree"
fi

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration
export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='code'
fi

# Compilation flags
export ARCHFLAGS="-arch arm64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
EOF

# Make zsh the default shell
if [ "$SHELL" != "/bin/zsh" ] && [ "$SHELL" != "/opt/homebrew/bin/zsh" ]; then
    echo "🔄 Setting zsh as default shell..."
    if [[ $(uname -m) == "arm64" ]]; then
        echo "Please run: chsh -s /opt/homebrew/bin/zsh"
        echo "Then restart your terminal or run: exec zsh"
    else
        echo "Please run: chsh -s /bin/zsh"
        echo "Then restart your terminal or run: exec zsh"
    fi
else
    echo "✅ zsh is already the default shell"
fi

echo ""
echo "🎉 zsh environment setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Restart your terminal or run: exec zsh"
echo "2. If you haven't set zsh as default shell, run:"
if [[ $(uname -m) == "arm64" ]]; then
    echo "   chsh -s /opt/homebrew/bin/zsh"
else
    echo "   chsh -s /bin/zsh"
fi
echo "3. Powerlevel10k will prompt you to configure the theme on first run"
echo ""
echo "🔧 Available commands:"
echo "   ls, ll, la, lt  - eza commands (modern ls replacement)"
echo "   git commands    - enhanced with Oh My Zsh"
echo ""
echo "📚 Useful files:"
echo "   ~/.zshrc        - Main configuration file"
echo "   ~/.oh-my-zsh/   - Oh My Zsh installation"
echo ""
