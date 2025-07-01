#!/bin/bash

# Install zsh environment for UCR HPC (no admin permissions)
# This script installs zsh, Oh My Zsh, plugins, theme, and eza in home directory

set -e  # Exit on any error

echo "🚀 Starting zsh environment setup for UCR HPC..."

# Check if running on Linux (HPC environment)
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "❌ This script is designed for Linux HPC environments"
    exit 1
fi

# Set installation directories in home
INSTALL_DIR="$HOME/.local"
BIN_DIR="$INSTALL_DIR/bin"
ZSH_DIR="$HOME/.oh-my-zsh"
CONDA_DIR="$HOME/miniconda3"

echo "📁 Installation directories:"
echo "   Binaries: $BIN_DIR"
echo "   Oh My Zsh: $ZSH_DIR"
echo "   Conda: $CONDA_DIR"

# Create necessary directories
mkdir -p "$BIN_DIR"
mkdir -p "$ZSH_DIR"
mkdir -p "$HOME/.zsh"

# Add local bin to PATH if not already there
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    export PATH="$BIN_DIR:$PATH"
fi

# Check if conda/mamba is available
if command -v conda &> /dev/null; then
    echo "✅ Conda is available"
    CONDA_CMD="conda"
elif command -v mamba &> /dev/null; then
    echo "✅ Mamba is available"
    CONDA_CMD="mamba"
elif [ -f "$CONDA_DIR/bin/conda" ]; then
    echo "✅ Found conda in $CONDA_DIR"
    CONDA_CMD="$CONDA_DIR/bin/conda"
    export PATH="$CONDA_DIR/bin:$PATH"
else
    echo "📦 Installing Miniconda..."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
    bash ~/miniconda.sh -b -p "$CONDA_DIR"
    rm ~/miniconda.sh
    CONDA_CMD="$CONDA_DIR/bin/conda"
    export PATH="$CONDA_DIR/bin:$PATH"
    echo 'export PATH="$HOME/miniconda3/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="$HOME/miniconda3/bin:$PATH"' >> ~/.zshrc
fi

# Install zsh if not available
if ! command -v zsh &> /dev/null; then
    echo "📦 Installing zsh via conda..."
    $CONDA_CMD install -c conda-forge zsh -y
else
    echo "✅ zsh is already available"
fi

# Install eza via conda
echo "📦 Installing eza..."
$CONDA_CMD install -c conda-forge eza -y

# Install git if not available
if ! command -v git &> /dev/null; then
    echo "📦 Installing git via conda..."
    $CONDA_CMD install -c conda-forge git -y
else
    echo "✅ git is already available"
fi

# Install Oh My Zsh
if [ ! -d "$ZSH_DIR" ]; then
    echo "📦 Installing Oh My Zsh..."
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR"
else
    echo "✅ Oh My Zsh is already installed"
fi

# Install Powerlevel10k theme
if [ ! -d "$ZSH_DIR/custom/themes/powerlevel10k" ]; then
    echo "🎨 Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_DIR/custom/themes/powerlevel10k"
else
    echo "✅ Powerlevel10k theme is already installed"
fi

# Install zsh plugins
echo "🔌 Installing zsh plugins..."

# zsh-completions
if [ ! -d "$ZSH_DIR/custom/plugins/zsh-completions" ]; then
    git clone https://github.com/zsh-users/zsh-completions.git "$ZSH_DIR/custom/plugins/zsh-completions"
else
    echo "✅ zsh-completions is already installed"
fi

# zsh-autosuggestions
if [ ! -d "$ZSH_DIR/custom/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_DIR/custom/plugins/zsh-autosuggestions"
else
    echo "✅ zsh-autosuggestions is already installed"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_DIR/custom/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_DIR/custom/plugins/zsh-syntax-highlighting"
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

# Create new .zshrc with HPC-specific configuration
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

# HPC-specific environment
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/miniconda3/bin:$PATH"

# eza aliases (modern ls replacement)
if command -v eza > /dev/null; then
  alias ls="eza"
  alias ll="eza -l"
  alias la="eza -la"
  alias lt="eza --tree"
fi

# HPC-specific aliases
alias qstat="squeue"
alias qsub="sbatch"
alias qdel="scancel"

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
  export EDITOR='nano'
fi

# HPC-specific settings
export TMPDIR="/tmp"
export TEMP="/tmp"

# Load any available modules (if using Lmod)
if command -v module &> /dev/null; then
    # Uncomment and modify as needed for your HPC
    # module load git
    # module load conda
fi

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
EOF

# Create a simple script to switch to zsh
cat > "$BIN_DIR/switch-to-zsh" << 'EOF'
#!/bin/bash
echo "Switching to zsh..."
exec zsh
EOF

chmod +x "$BIN_DIR/switch-to-zsh"

echo ""
echo "🎉 zsh environment setup complete for UCR HPC!"
echo ""
echo "📝 Next steps:"
echo "1. Add to your ~/.bashrc or ~/.profile:"
echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
echo "2. To use zsh, run: switch-to-zsh"
echo "3. Or start a new session with: exec zsh"
echo "4. Powerlevel10k will prompt you to configure the theme on first run"
echo ""
echo "🔧 Available commands:"
echo "   switch-to-zsh  - Switch to zsh session"
echo "   ls, ll, la, lt - eza commands (modern ls replacement)"
echo "   qstat, qsub, qdel - HPC job management aliases"
echo ""
echo "📚 Useful files:"
echo "   ~/.zshrc        - Main configuration file"
echo "   ~/.oh-my-zsh/   - Oh My Zsh installation"
echo "   ~/.local/bin/   - Local binaries"
echo ""
echo "⚠️  Note: This installation is in your home directory and doesn't require admin permissions."
echo ""
