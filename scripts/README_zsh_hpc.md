# ZSH Environment Installation for UCR HPC

## 📧 Email Instructions for HPC Users

This package contains everything needed to set up a professional zsh environment on UCR HPC **without requiring admin permissions**.

## 📦 What's Included

- **install_zsh_hpc.sh** - Automated installation script for HPC
- **README_zsh_hpc.md** - This instruction file

## 🚀 Quick Installation

### Step 1: Upload and Extract

```bash
# Upload the file to your HPC home directory
# Extract the compressed file
tar -xzf zsh_hpc_install.tar.gz
cd zsh_hpc_install
```

### Step 2: Run the Installation Script

```bash
# Make the script executable and run it
chmod +x install_zsh_hpc.sh
./install_zsh_hpc.sh
```

### Step 3: Switch to ZSH

```bash
# Use the provided script to switch to zsh
switch-to-zsh

# Or manually
exec zsh
```

## 🎨 What Gets Installed

✅ **Miniconda** - Package manager (installed in home directory)
✅ **zsh** - Advanced shell (via conda)
✅ **Oh My Zsh** - Framework for managing zsh configuration
✅ **Powerlevel10k** - Beautiful and functional theme
✅ **eza** - Modern ls replacement with colors and icons
✅ **zsh-completions** - Additional completion definitions
✅ **zsh-autosuggestions** - Fish-like autosuggestions
✅ **zsh-syntax-highlighting** - Syntax highlighting for zsh

## 🔧 HPC-Specific Features

- **No Admin Permissions Required** - Everything installed in `$HOME`
- **HPC Job Management Aliases**:
  - `qstat` → `squeue` (check job status)
  - `qsub` → `sbatch` (submit jobs)
  - `qdel` → `scancel` (cancel jobs)
- **Module System Ready** - Configured for Lmod/Environment Modules
- **Home Directory Installation** - All tools in `~/.local/bin`

## ⚠️ Important Notes

- **Home Directory Only**: All installations are in your home directory
- **No System Changes**: Doesn't modify system files or require sudo
- **Backup**: Automatically backs up existing `.zshrc`
- **Conda/Mamba**: Uses conda for package management
- **HPC Optimized**: Configured for cluster environments

## 🆘 Troubleshooting

### If conda/mamba is not available

The script will automatically install Miniconda in your home directory.

### If you can't access git

```bash
# Load git module if available
module load git

# Or install via conda
conda install -c conda-forge git -y
```

### If zsh isn't working

```bash
# Check if zsh is in your PATH
which zsh

# Add to your ~/.bashrc
echo 'export PATH="$HOME/miniconda3/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### If you want to revert

```bash
# Restore your original .zshrc
cp ~/.zshrc.backup.* ~/.zshrc

# Remove installations
rm -rf ~/.oh-my-zsh
rm -rf ~/.local/bin/switch-to-zsh
```

## 🔧 Available Commands

- **switch-to-zsh** - Switch from bash to zsh session
- **ls, ll, la, lt** - eza commands (modern ls replacement)
- **qstat, qsub, qdel** - HPC job management aliases

## 📚 Installation Locations

- **Binaries**: `~/.local/bin/`
- **Oh My Zsh**: `~/.oh-my-zsh/`
- **Conda**: `~/miniconda3/`
- **Configuration**: `~/.zshrc`

## 🎯 UCR HPC Specific

### Module System

The script is configured to work with UCR's module system. You can add module loads to your `.zshrc`:

```bash
# Edit your .zshrc and uncomment/modify these lines:
# module load git
# module load conda
# module load python
```

### Job Submission

Use the provided aliases for SLURM job management:

```bash
qsub my_job.sh    # Submit job
qstat             # Check job status
qdel 12345        # Cancel job
```

## 📞 Support

If you encounter issues:

1. Check you're on a Linux HPC system
2. Verify you have write access to your home directory
3. Ensure your internet connection is stable
4. Check if conda/mamba is available on your system

## 🎉 Enjoy Your New HPC Terminal

After installation, you'll have a professional, feature-rich terminal environment perfect for HPC work and research.
