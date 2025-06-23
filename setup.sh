#!/usr/bin/env bash
set -euo pipefail

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

# 0. Project name (for the .Rproj file)
PROJECT_NAME="RNAseqDiapauseAnalysis"

info "Starting RNA-seq Differential Expression Analysis setup..."

# Detect architecture
detect_architecture() {
    local arch=$(uname -m)
    case $arch in
        x86_64)
            echo "linux-64"
            ;;
        aarch64|arm64)
            echo "linux-aarch64"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

ARCH=$(detect_architecture)
info "Detected architecture: $ARCH ($(uname -m))"

# 1. Create minimal RStudio project file
info "Creating RStudio project file: ${PROJECT_NAME}.Rproj"
cat > "${PROJECT_NAME}.Rproj" <<EOF
Version: 1.0
RestoreWorkspace: No
SaveWorkspace: No
AlwaysSaveHistory: Default
EnableCodeIndexing: Yes
UseSpacesForTab: Yes
NumSpacesForTab: 2
Encoding: UTF-8
RnwWeave: Sweave
LaTeX: pdfLaTeX
EOF

# 2. Make directory structure
info "Creating directory tree…"
mkdir -p data/{raw,metadata,references}
mkdir -p scripts/{differential_expression,download}
mkdir -p logs

# 3. Enhanced environment detection and setup
detect_environment() {
    if command -v micromamba >/dev/null 2>&1; then
        echo "micromamba"
    elif command -v mamba >/dev/null 2>&1; then
        echo "mamba"
    elif command -v conda >/dev/null 2>&1; then
        echo "conda"
    else
        echo "none"
    fi
}

CONDA_CMD=$(detect_environment)
info "Detected package manager: ${CONDA_CMD}"

if [[ "$CONDA_CMD" == "none" ]]; then
    error "No conda/mamba/micromamba found. Please install one of them first."
    exit 1
fi

# Install working Bioconductor packages
install_bioconductor_packages() {
    info "Installing Bioconductor packages..."
    
    local core_packages=("DESeq2" "tximport" "AnnotationDbi" "biomaRt" "sva")
    local missing_packages=()
    
    # Check which packages are missing
    for package in "${core_packages[@]}"; do
        if ! Rscript -e "library($package)" >/dev/null 2>&1; then
            missing_packages+=("$package")
        else
            success "$package already available"
        fi
    done
    
    # If packages are missing, try micromamba first, then R
    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        info "Missing packages: ${missing_packages[*]}"
        info "Trying installation via micromamba..."
        
        # Convert package names to bioconductor format
        local conda_packages=()
        for package in "${missing_packages[@]}"; do
            conda_packages+=("bioconductor-$(echo $package | tr '[:upper:]' '[:lower:]')")
        done
        
        # Try micromamba installation
        if $CONDA_CMD install -n base -c conda-forge -c bioconda "${conda_packages[@]}" -y >/dev/null 2>&1; then
            success "Bioconductor packages installed via micromamba"
        else
            warning "Micromamba installation failed, trying R installation..."
            
            # Fallback to R installation
            if ! Rscript -e "library(BiocManager)" >/dev/null 2>&1; then
                info "Installing BiocManager..."
                Rscript -e "install.packages('BiocManager', repos='https://cloud.r-project.org/')"
            fi
            
            for package in "${missing_packages[@]}"; do
                info "Installing $package via R..."
                if Rscript -e "library(BiocManager); BiocManager::install('$package', ask=FALSE, update=FALSE)" >/dev/null 2>&1; then
                    success "$package installed successfully"
                else
                    warning "Failed to install $package - will try to continue"
                fi
            done
        fi
    fi
}

# Install missing R packages
install_missing_r_packages() {
    info "Installing missing R packages..."
    
    local essential_packages=("DESeq2" "tximport" "tidyverse" "metafor" "here" "data.table")
    local optional_packages=("biomaRt" "AnnotationDbi")
    local missing_essential=()
    local missing_optional=()
    
    # Check essential packages
    for package in "${essential_packages[@]}"; do
        if ! Rscript -e "if(require('$package', quietly=TRUE)) quit(status=0) else quit(status=1)" >/dev/null 2>&1; then
            missing_essential+=("$package")
        fi
    done
    
    # Check optional packages
    for package in "${optional_packages[@]}"; do
        if ! Rscript -e "if(require('$package', quietly=TRUE)) quit(status=0) else quit(status=1)" >/dev/null 2>&1; then
            missing_optional+=("$package")
        fi
    done
    
    # Install missing essential packages
    if [[ ${#missing_essential[@]} -gt 0 ]]; then
        info "Installing missing essential R packages: ${missing_essential[*]}"
        for package in "${missing_essential[@]}"; do
            info "Installing $package..."
            if [[ "$package" == "tidyverse" || "$package" == "metafor" || "$package" == "here" || "$package" == "data.table" ]]; then
                # CRAN packages
                if Rscript -e "install.packages('$package', repos='https://cloud.r-project.org/')" >/dev/null 2>&1; then
                    success "$package installed successfully"
                else
                    warning "Failed to install $package"
                fi
            else
                # Bioconductor packages
                if Rscript -e "library(BiocManager); BiocManager::install('$package', ask=FALSE, update=FALSE)" >/dev/null 2>&1; then
                    success "$package installed successfully"
                else
                    warning "Failed to install $package"
                fi
            fi
        done
    fi
    
    # Install missing optional packages
    if [[ ${#missing_optional[@]} -gt 0 ]]; then
        info "Installing missing optional R packages: ${missing_optional[*]}"
        for package in "${missing_optional[@]}"; do
            info "Installing $package..."
            if Rscript -e "library(BiocManager); BiocManager::install('$package', ask=FALSE, update=FALSE)" >/dev/null 2>&1; then
                success "$package installed successfully"
            else
                warning "Failed to install $package - continuing anyway"
            fi
        done
    fi
}

# Install missing Python plotting libraries
install_python_plotting() {
    info "Checking Python plotting libraries..."
    
    # Install libstdcxx-ng first
    info "Installing libstdcxx-ng..."
    $CONDA_CMD install -c conda-forge libstdcxx-ng -y
    
    # Set LD_LIBRARY_PATH (handle unbound variable)
    if [[ -z "${LD_LIBRARY_PATH:-}" ]]; then
        export LD_LIBRARY_PATH=/opt/conda/lib
    else
        export LD_LIBRARY_PATH=/opt/conda/lib:$LD_LIBRARY_PATH
    fi
    
    # Check for GLIBCXX compatibility issue
    info "Checking GLIBCXX compatibility..."
    local max_glibcxx=$(strings /lib/aarch64-linux-gnu/libstdc++.so.6 2>/dev/null | grep GLIBCXX | tail -1 | sed 's/GLIBCXX_//')
    if [[ -n "$max_glibcxx" ]]; then
        info "System GLIBCXX max version: $max_glibcxx"
    fi
    
    # Install compatible kiwisolver first if needed
    if python -c "import kiwisolver" >/dev/null 2>&1; then
        local kiwisolver_version=$(python -c "import kiwisolver; print(kiwisolver.__version__)" 2>/dev/null)
        info "kiwisolver version: $kiwisolver_version"
        
        # Check if we need to downgrade kiwisolver
        if [[ "$kiwisolver_version" == "1.4."* ]]; then
            info "Downgrading kiwisolver to compatible version..."
            pip uninstall kiwisolver -y >/dev/null 2>&1 || true
            pip install "kiwisolver<1.4.0" >/dev/null 2>&1
            success "kiwisolver downgraded successfully"
        fi
    else
        info "Installing compatible kiwisolver..."
        pip install "kiwisolver<1.4.0" >/dev/null 2>&1
        success "kiwisolver installed successfully"
    fi
    
    local plotting_libs=("matplotlib" "seaborn" "plotnine" "upsetplot" "bokeh" "altair" "holoviews")
    local missing_libs=()
    
    # Check which plotting libraries are missing
    for lib in "${plotting_libs[@]}"; do
        if ! python -c "import $lib" >/dev/null 2>&1; then
            missing_libs+=("$lib")
        else
            success "$lib already available"
        fi
    done
    
    if [[ ${#missing_libs[@]} -eq 0 ]]; then
        success "All Python plotting libraries are available!"
        return 0
    fi
    
    info "Missing Python plotting libraries: ${missing_libs[*]}"
    info "Installing via pip..."
    
    # Try installing via pip first
    if pip install "${missing_libs[@]}" >/dev/null 2>&1; then
        success "Python plotting libraries installed successfully via pip"
    else
        warning "Pip installation failed, trying conda..."
        
        # Fallback to conda installation
        if $CONDA_CMD install -c conda-forge "${missing_libs[@]}" -y >/dev/null 2>&1; then
            success "Python plotting libraries installed successfully via conda"
        else
            warning "Failed to install some Python plotting libraries"
        fi
    fi
}

# Test Python plotting libraries
test_python_plotting() {
    info "Testing Python plotting libraries..."
    
    # Test matplotlib import
    if python -c "import matplotlib.pyplot as plt; print('matplotlib OK')" >/dev/null 2>&1; then
        success "matplotlib import test passed"
    else
        error "matplotlib import test failed"
        return 1
    fi
    
    # Test kiwisolver import
    if python -c "import kiwisolver; print('kiwisolver OK')" >/dev/null 2>&1; then
        success "kiwisolver import test passed"
    else
        error "kiwisolver import test failed"
        return 1
    fi
    
    # Test basic plotting
    if python -c "import matplotlib.pyplot as plt; plt.figure(); plt.close(); print('matplotlib plotting OK')" >/dev/null 2>&1; then
        success "matplotlib plotting test passed"
    else
        error "matplotlib plotting test failed"
        return 1
    fi
    
    return 0
}

# Enhanced environment information
print_environment_info() {
    info "Environment Information:"
    echo "  OS: $(uname -s) $(uname -r)"
    echo "  Architecture: $(uname -m) (conda: $ARCH)"
    echo "  Package manager: $CONDA_CMD"
    if command -v python >/dev/null 2>&1; then
        echo "  Python: $(python --version 2>&1)"
    fi
    if command -v R >/dev/null 2>&1; then
        echo "  R: $(R --version 2>&1 | head -1)"
    fi
    echo "  PATH: $PATH"
    echo "  R Library paths: $(Rscript -e 'cat(.libPaths(), sep="\n")')"
}

# 4. Create metadata files
info "Creating metadata files..."

# Create candidate genes list
info "Creating candidate genes list..."
cat > "data/metadata/candidate_genes.txt" <<EOF
# Candidate genes for RNA-seq analysis
# Format: gene_id,gene_name,description
# Add your candidate genes below:
EOF

success "Metadata files created successfully"

# Main execution flow

# Print environment info
print_environment_info

# Install Bioconductor packages
install_bioconductor_packages

# Install missing R packages
install_missing_r_packages

# Install Python plotting libraries
install_python_plotting

# Test Python plotting libraries
test_python_plotting

# Create a setup log
{
    echo "Setup completed at: $(date)"
    echo "Environment: $(uname -a)"
    echo "Package manager: $CONDA_CMD"
    echo "Architecture: $ARCH"
} > logs/setup.log

success "setup.sh complete!"
info "Setup log saved to: logs/setup.log"

# Final tool verification summary
echo ""
info "Final Tool Installation Summary:"
echo "Essential R packages:"
for package in DESeq2 tximport tidyverse metafor here data.table sva biomaRt; do
    if Rscript -e "library($package)" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} $package"
    else
        echo -e "  ${RED}✗${NC} $package"
    fi
done

echo ""
info "Next steps:"
echo "1. Copy your organized results to results/analysis/"
echo "2. Run differential expression analysis scripts"
echo "3. Generate visualizations"

echo ""
success "setup.sh complete! Ready for RNA-seq differential expression analysis."