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
mkdir -p data/{raw,metadata,references,processed,logs,sra}
mkdir -p data/raw/{PRJNA268379,PRJNA158021,PRJNA187045}
mkdir -p scripts/{differential_expression,download,analysis,visualization,qc}
mkdir -p output/{tables,figures,qc,differential_expression}
mkdir -p output/figures/publication
mkdir -p results/zenodo
mkdir -p logs
mkdir -p nf-core/configs

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

# Check Bioconductor packages
check_bioconductor_packages() {
    info "Checking Bioconductor packages..."
    
    local core_packages=("DESeq2" "tximport" "AnnotationDbi" "biomaRt" "sva")
    local missing_packages=()
    
    # Check which packages are missing
    for package in "${core_packages[@]}"; do
        if ! Rscript -e "library($package)" >/dev/null 2>&1; then
            missing_packages+=("$package")
        else
            success "$package available"
        fi
    done
    
    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        warning "Missing Bioconductor packages: ${missing_packages[*]}"
        return 1
    else
        success "All Bioconductor packages are available!"
        return 0
    fi
}

# Check R packages
check_r_packages() {
    info "Checking R packages..."
    
    local essential_packages=("DESeq2" "tximport" "tidyverse" "metafor" "here" "data.table")
    local optional_packages=("biomaRt" "AnnotationDbi")
    local missing_essential=()
    local missing_optional=()
    
    # Check essential packages
    for package in "${essential_packages[@]}"; do
        if ! Rscript -e "if(require('$package', quietly=TRUE)) quit(status=0) else quit(status=1)" >/dev/null 2>&1; then
            missing_essential+=("$package")
        else
            success "$package available"
        fi
    done
    
    # Check optional packages
    for package in "${optional_packages[@]}"; do
        if ! Rscript -e "if(require('$package', quietly=TRUE)) quit(status=0) else quit(status=1)" >/dev/null 2>&1; then
            missing_optional+=("$package")
        else
            success "$package available"
        fi
    done
    
    if [[ ${#missing_essential[@]} -gt 0 ]]; then
        warning "Missing essential R packages: ${missing_essential[*]}"
        return 1
    fi
    
    if [[ ${#missing_optional[@]} -gt 0 ]]; then
        warning "Missing optional R packages: ${missing_optional[*]}"
    fi
    
    success "All essential R packages are available!"
    return 0
}

# Check Python plotting libraries
check_python_plotting() {
    info "Checking Python plotting libraries..."
    
    local plotting_libs=("matplotlib" "seaborn" "plotnine" "upsetplot" "bokeh" "altair" "holoviews")
    local missing_libs=()
    
    # Check which plotting libraries are missing
    for lib in "${plotting_libs[@]}"; do
        if ! python -c "import $lib" >/dev/null 2>&1; then
            missing_libs+=("$lib")
        else
            success "$lib available"
        fi
    done
    
    if [[ ${#missing_libs[@]} -eq 0 ]]; then
        success "All Python plotting libraries are available!"
        return 0
    else
        warning "Missing Python plotting libraries: ${missing_libs[*]}"
        return 1
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

# Check Bioconductor packages
check_bioconductor_packages

# Check R packages
check_r_packages

# Check Python plotting libraries
check_python_plotting

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