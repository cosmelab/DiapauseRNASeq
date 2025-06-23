# RNA-seq Diapause Analysis - Setup Guide

## Directory Structure Setup

Create your project directory and organize files as follows:

```bash
mkdir rnaseq-diapause-analysis
cd rnaseq-diapause-analysis

# Create the following structure:
rnaseq-diapause-analysis/
├── .devcontainer/
│   └── devcontainer.json
├── .vscode/
│   └── settings.json
├── scripts/
│   └── download_datasets.sh
├── Dockerfile
├── docker-compose.yml
├── setup.sh
├── start_jupyter.sh
├── .gitignore
├── rnaseq-diapause-analysis.code-workspace
└── README.md
```

## File Placement

1. **Save devcontainer.json** as `.devcontainer/devcontainer.json`
2. **Save workspace settings** as `.vscode/settings.json` 
3. **Save workspace file** as `rnaseq-diapause-analysis.code-workspace`
4. **Save other files** in the root directory

## VSCode/Cursor Integration Options

### Option 1: Dev Container (Recommended)
- Open the project folder in VSCode/Cursor
- Install "Dev Containers" extension
- VSCode will detect `.devcontainer/devcontainer.json`
- Click "Reopen in Container" when prompted
- Everything will be automatically configured!

### Option 2: Docker Compose (Manual)
```bash
# Build and start container
docker-compose up -d

# Connect VSCode to running container
# Use "Remote-Containers: Attach to Running Container"
# Select: rnaseq-diapause-container
```

### Option 3: Workspace File
```bash
# Open the workspace file directly
code rnaseq-diapause-analysis.code-workspace
```

## What Each Configuration Does

### `.devcontainer/devcontainer.json`
- **Automatic container setup** when opening in VSCode
- **Extension installation** (Python, R, Jupyter, etc.)
- **Port forwarding** for Jupyter Lab (8888)
- **Terminal configuration** (zsh with oh-my-zsh)
- **Post-creation commands** (runs setup.sh automatically)

### `.vscode/settings.json`
- **Python/R interpreter paths** for proper IntelliSense
- **File associations** for bioinformatics formats
- **Search exclusions** for large data files
- **Terminal defaults** (zsh)
- **Editor settings** (tabs, rulers, etc.)

### `rnaseq-diapause-analysis.code-workspace`
- **Multi-folder workspace** setup
- **Launch configurations** for debugging
- **Recommended extensions** list
- **Project-specific settings**

### `.gitignore`
- **Excludes large data files** from version control
- **Keeps important scripts and results**
- **Standard patterns** for R, Python, Docker

## Quick Start Commands

```bash
# Method 1: Dev Container (easiest)
code .  # VSCode will prompt to open in container

# Method 2: Manual Docker
docker-compose up -d
docker-compose exec rnaseq-analysis zsh

# Method 3: Workspace file
code rnaseq-diapause-analysis.code-workspace
```

## Benefits of This Setup

✅ **Automatic environment setup** - No manual configuration needed  
✅ **Integrated terminal** with zsh and oh-my-zsh  
✅ **Python/R IntelliSense** and debugging  
✅ **Jupyter Lab integration** with port forwarding  
✅ **Git integration** with smart file exclusions  
✅ **Extension recommendations** for bioinformatics  
✅ **File type associations** for FASTA, FASTQ, etc.  

The dev container approach is recommended because it provides the most seamless experience - VSCode will automatically build the container, install extensions, and configure everything for you!