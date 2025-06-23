#!/bin/bash

# Configuration
HPC_USER="lcosme"
HPC_HOST="cluster.hpcc.ucr.edu"
HPC_DIR="/bigdata/cosmelab/lcosme/docker/results"
LOCAL_DIR="results"

# Color output functions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Create local directory if it doesn't exist
mkdir -p "$LOCAL_DIR"

# Main script - download zenodo directory
info "Starting data transfer from HPC..."
info "Downloading zenodo/ directory..."

# Single rsync command to download zenodo directory
if rsync -avz --progress \
    --include="zenodo/***" \
    --exclude="*" \
    "$HPC_USER@$HPC_HOST:$HPC_DIR/" \
    "$LOCAL_DIR/"; then
    success "Transfer complete!"
else
    error "Transfer failed"
    exit 1
fi

info "Data has been downloaded to $LOCAL_DIR"
info "Zenodo-ready data in: $LOCAL_DIR/zenodo/"

# Show directory structure
info "Directory structure:"
if command -v tree >/dev/null 2>&1; then
    tree "$LOCAL_DIR/zenodo" -L 2
else
    find "$LOCAL_DIR/zenodo" -type d | head -20
fi