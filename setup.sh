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

# Project name
PROJECT_NAME="RNAseqDiapauseAnalysis"

info "Starting RNA-seq Differential Expression Analysis setup..."

# 1. Create RStudio project file
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

# 2. Create directory structure
info "Creating directory tree..."
mkdir -p data/{raw,metadata,references,processed,logs}
mkdir -p scripts/{differential_expression,download,visualization,qc,quantification}
mkdir -p results/{analysis,figures,tables}
mkdir -p logs
mkdir -p output
mkdir -p nf-core/configs

# 3. Create basic metadata files
info "Creating metadata files..."

# Create candidate genes list
info "Creating candidate genes list..."
cat > "data/metadata/candidate_genes.txt" <<EOF
# Candidate genes for RNA-seq analysis
# Format: gene_id,gene_name,description
# Add your candidate genes below:
EOF

# Create samples metadata template
info "Creating samples metadata template..."
cat > "data/metadata/samples.csv" <<EOF
sample_id,condition,replicate,file_path
# Add your sample information below:
# Example:
# SRR123456,diapause,1,data/raw/SRR123456.fastq.gz
# SRR123457,non-diapause,1,data/raw/SRR123457.fastq.gz
EOF

# 4. Create basic README for each directory
info "Creating README files..."

cat > "data/README.md" <<EOF
# Data Directory

## Structure
- \`raw/\`: Raw sequencing data (FASTQ files)
- \`metadata/\`: Sample information and experimental design
- \`references/\`: Reference genomes and annotations
- \`processed/\`: Intermediate processed files
- \`logs/\`: Processing logs

## Usage
Place your raw sequencing data in the \`raw/\` directory.
Update \`metadata/samples.csv\` with your sample information.
EOF

cat > "scripts/README.md" <<EOF
# Scripts Directory

## Structure
- \`differential_expression/\`: DE analysis scripts
- \`download/\`: Data download scripts
- \`visualization/\`: Plotting and visualization scripts
- \`qc/\`: Quality control scripts
- \`quantification/\`: Expression quantification scripts

## Usage
Run scripts from the project root directory.
EOF

cat > "results/README.md" <<EOF
# Results Directory

## Structure
- \`analysis/\`: Analysis results and intermediate files
- \`figures/\`: Generated plots and visualizations
- \`tables/\`: Summary tables and statistics

## Usage
Analysis outputs will be saved here automatically.
EOF

# 5. Create environment info
info "Creating environment information..."
{
    echo "Setup completed at: $(date)"
    echo "Environment: $(uname -a)"
    echo "Working directory: $(pwd)"
    echo "Project structure created successfully"
} > logs/setup.log

success "setup.sh complete!"
info "Setup log saved to: logs/setup.log"

echo ""
info "Project structure created:"
echo "  📁 data/ - Raw data and metadata"
echo "  📁 scripts/ - Analysis scripts"
echo "  📁 results/ - Analysis outputs"
echo "  📁 logs/ - Log files"
echo "  📁 output/ - Pipeline outputs"
echo "  📁 nf-core/ - nf-core configurations"

echo ""
info "Next steps:"
echo "1. Add your raw sequencing data to data/raw/"
echo "2. Update data/metadata/samples.csv with sample information"
echo "3. Add reference files to data/references/"
echo "4. Run your analysis scripts"

echo ""
success "setup.sh complete! Ready for RNA-seq analysis." 