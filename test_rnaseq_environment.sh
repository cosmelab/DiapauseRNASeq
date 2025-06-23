#!/bin/bash

echo "🧬 Testing Complete RNA-seq Pipeline Environment"
echo "=============================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

test_tool() {
    local tool=$1
    local test_cmd=$2
    local is_essential=${3:-false}
    
    if eval "$test_cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $tool${NC}"
        return 0
    else
        if [[ "$is_essential" == "true" ]]; then
            echo -e "${RED}❌ $tool (ESSENTIAL)${NC}"
        else
            echo -e "${YELLOW}⚠️  $tool (optional)${NC}"
        fi
        return 1
    fi
}

test_python_import() {
    local package=$1
    local is_essential=${2:-false}
    
    if python -c "import $package" >/dev/null 2>&1; then
        local version=$(python -c "import $package; print(getattr($package, '__version__', 'unknown'))" 2>/dev/null || echo "unknown")
        echo -e "${GREEN}✅ $package${NC} ($version)"
        return 0
    else
        if [[ "$is_essential" == "true" ]]; then
            echo -e "${RED}❌ $package (ESSENTIAL)${NC}"
        else
            echo -e "${YELLOW}⚠️  $package (optional)${NC}"
        fi
        return 1
    fi
}

test_r_package() {
    local package=$1
    local is_essential=${2:-false}
    
    if Rscript -e "library($package)" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $package${NC}"
        return 0
    else
        if [[ "$is_essential" == "true" ]]; then
            echo -e "${RED}❌ $package (ESSENTIAL)${NC}"
        else
            echo -e "${YELLOW}⚠️  $package (optional)${NC}"
        fi
        return 1
    fi
}

# Track failed tests
FAILED_ESSENTIAL=0
FAILED_OPTIONAL=0

echo "🔧 System Tools & Environment:"
test_tool "bash" "bash --version" true || ((FAILED_ESSENTIAL++))
test_tool "zsh" "zsh --version" false || ((FAILED_OPTIONAL++))
test_tool "curl" "curl --version" true || ((FAILED_ESSENTIAL++))
test_tool "git" "git --version" true || ((FAILED_ESSENTIAL++))
test_tool "unzip" "unzip -v" true || ((FAILED_ESSENTIAL++))
test_tool "java" "java -version" true || ((FAILED_ESSENTIAL++))
test_tool "cmake" "cmake --version" false || ((FAILED_OPTIONAL++))
test_tool "parallel" "parallel --version" false || ((FAILED_OPTIONAL++))

echo ""
echo "📦 Package Managers:"
test_tool "micromamba" "micromamba --version" true || ((FAILED_ESSENTIAL++))
test_tool "pip" "pip --version" true || ((FAILED_ESSENTIAL++))

echo ""
echo "🐍 Core Python Environment:"
test_tool "python" "python --version" true || ((FAILED_ESSENTIAL++))
test_python_import "numpy" true || ((FAILED_ESSENTIAL++))
test_python_import "pandas" true || ((FAILED_ESSENTIAL++))
test_python_import "scipy" false || ((FAILED_OPTIONAL++))
test_python_import "matplotlib" true || ((FAILED_ESSENTIAL++))
test_python_import "seaborn" false || ((FAILED_OPTIONAL++))
test_python_import "scikit-learn" false || ((FAILED_OPTIONAL++))
test_python_import "statsmodels" false || ((FAILED_OPTIONAL++))

echo ""
echo "📊 Advanced Python Visualization:"
test_python_import "bokeh" false || ((FAILED_OPTIONAL++))
test_python_import "altair" false || ((FAILED_OPTIONAL++))
test_python_import "holoviews" false || ((FAILED_OPTIONAL++))
test_python_import "plotnine" false || ((FAILED_OPTIONAL++))
test_python_import "upsetplot" false || ((FAILED_OPTIONAL++))

echo ""
echo "🧬 Bioinformatics Python Libraries:"
test_python_import "Bio" true || ((FAILED_ESSENTIAL++))
test_python_import "pysam" false || ((FAILED_OPTIONAL++))

echo ""
echo "🌐 Web & File I/O Python:"
test_python_import "requests" false || ((FAILED_OPTIONAL++))
test_python_import "lxml" false || ((FAILED_OPTIONAL++))
test_python_import "bs4" false || ((FAILED_OPTIONAL++))
test_python_import "xmltodict" false || ((FAILED_OPTIONAL++))

echo ""
echo "📓 Jupyter Environment:"
test_tool "jupyter" "jupyter --version" false || ((FAILED_OPTIONAL++))
test_tool "jupyterlab" "jupyter lab --version" false || ((FAILED_OPTIONAL++))

echo ""
echo "🔬 Essential RNA-seq Tools:"
test_tool "salmon" "salmon --version" true || ((FAILED_ESSENTIAL++))
test_tool "fastqc" "fastqc --version" true || ((FAILED_ESSENTIAL++))
test_tool "multiqc" "multiqc --version" true || ((FAILED_ESSENTIAL++))
test_tool "fastp" "fastp --version" true || ((FAILED_ESSENTIAL++))
test_tool "nextflow" "nextflow -version" true || ((FAILED_ESSENTIAL++))
test_tool "samtools" "samtools --version" true || ((FAILED_ESSENTIAL++))
test_tool "bedtools" "bedtools --version" true || ((FAILED_ESSENTIAL++))

echo ""
echo "📥 SRA Data Download Tools:"
test_tool "fastq-dump" "fastq-dump --version" false || ((FAILED_OPTIONAL++))
test_tool "prefetch" "prefetch --version" false || ((FAILED_OPTIONAL++))
test_tool "vdb-config" "vdb-config --version" false || ((FAILED_OPTIONAL++))

echo ""
echo "🧪 Additional Bioinformatics Tools:"
test_tool "bcftools" "bcftools --version" false || ((FAILED_OPTIONAL++))
test_tool "tabix" "tabix --version" false || ((FAILED_OPTIONAL++))
test_tool "vcftools" "vcftools --version" false || ((FAILED_OPTIONAL++))

echo ""
echo "🔍 NCBI Entrez Direct Tools:"
test_tool "esearch" "esearch -version" false || ((FAILED_OPTIONAL++))
test_tool "efetch" "efetch -help" false || ((FAILED_OPTIONAL++))

echo ""
echo "📈 R Environment:"
test_tool "R" "R --version" true || ((FAILED_ESSENTIAL++))
test_tool "Rscript" "Rscript --version" true || ((FAILED_ESSENTIAL++))

echo ""
echo "📊 Essential R Packages:"
test_r_package "tidyverse" true || ((FAILED_ESSENTIAL++))
test_r_package "here" true || ((FAILED_ESSENTIAL++))
test_r_package "data.table" true || ((FAILED_ESSENTIAL++))
test_r_package "metafor" true || ((FAILED_ESSENTIAL++))
test_r_package "broom" false || ((FAILED_OPTIONAL++))

echo ""
echo "📁 R File I/O Packages:"
test_r_package "readr" false || ((FAILED_OPTIONAL++))
test_r_package "readxl" false || ((FAILED_OPTIONAL++))
test_r_package "writexl" false || ((FAILED_OPTIONAL++))

echo ""
echo "🧬 Bioconductor Packages:"
test_r_package "DESeq2" true || ((FAILED_ESSENTIAL++))
test_r_package "tximport" true || ((FAILED_ESSENTIAL++))
test_r_package "sva" true || ((FAILED_ESSENTIAL++))
test_r_package "edgeR" false || ((FAILED_OPTIONAL++))
test_r_package "limma" false || ((FAILED_OPTIONAL++))
test_r_package "biomaRt" true || ((FAILED_ESSENTIAL++))
test_r_package "AnnotationDbi" false || ((FAILED_OPTIONAL++))

echo ""
echo "📝 R Documentation & Development:"
test_r_package "knitr" false || ((FAILED_OPTIONAL++))
test_r_package "rmarkdown" false || ((FAILED_OPTIONAL++))
test_r_package "devtools" false || ((FAILED_OPTIONAL++))
test_r_package "remotes" false || ((FAILED_OPTIONAL++))

echo ""
echo "🧪 Functional Tests:"

# Test salmon functionality
echo -n "Testing salmon indexing... "
if echo -e ">test\nATCGATCGATCGATCG" | salmon index -t /dev/stdin -i test_index -k 7 >/dev/null 2>&1; then
    echo -e "${GREEN}✅ salmon functional${NC}"
    rm -rf test_index 2>/dev/null
else
    echo -e "${RED}❌ salmon functional${NC}"
    ((FAILED_ESSENTIAL++))
fi

# Test fastqc functionality  
echo -n "Testing fastqc... "
if echo -e "@test\nATCGATCG\n+\nIIIIIIII" > /tmp/test.fastq && fastqc /tmp/test.fastq -o /tmp >/dev/null 2>&1; then
    echo -e "${GREEN}✅ fastqc functional${NC}"
    rm -f /tmp/test.fastq /tmp/test_fastqc.* 2>/dev/null
else
    echo -e "${RED}❌ fastqc functional${NC}"
    ((FAILED_ESSENTIAL++))
fi

# Test R statistical workflow
echo -n "Testing R differential expression workflow... "
if Rscript -e "
suppressMessages({
  library(DESeq2)
  library(tximport)
  library(tidyverse)
  
  # Simulate count data
  counts <- matrix(rpois(400, 20), ncol=8)
  colnames(counts) <- paste0('sample_', 1:8)
  rownames(counts) <- paste0('gene_', 1:50)
  
  # Create colData
  colData <- data.frame(
    condition = factor(rep(c('control', 'treatment'), each=4)),
    row.names = colnames(counts)
  )
  
  # Create DESeq2 object
  dds <- DESeqDataSetFromMatrix(counts, colData, design = ~ condition)
  dds <- DESeq(dds, quiet=TRUE)
  results <- results(dds)
  
  # Test tidyverse functionality
  results_df <- as.data.frame(results) %>%
    rownames_to_column('gene_id') %>%
    filter(!is.na(padj))
  
  cat('R workflow successful\\n')
})" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ R differential expression workflow${NC}"
else
    echo -e "${RED}❌ R differential expression workflow${NC}"
    ((FAILED_ESSENTIAL++))
fi

# Test Python data science with matplotlib backend fix
echo -n "Testing Python data science workflow... "
if python -c "
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from Bio.Seq import Seq

# Create sample data
np.random.seed(42)
data = pd.DataFrame({
    'gene_id': [f'gene_{i}' for i in range(100)],
    'log2FC': np.random.normal(0, 2, 100),
    'pvalue': np.random.beta(2, 5, 100)
})

# Create volcano plot
plt.figure(figsize=(8, 6))
plt.scatter(data['log2FC'], -np.log10(data['pvalue']), alpha=0.7)
plt.xlabel('Log2 Fold Change')
plt.ylabel('-Log10 P-value')
plt.title('Volcano Plot')
plt.savefig('/tmp/volcano_test.png', dpi=150, bbox_inches='tight')
plt.close()

# Test biopython
seq = Seq('ATCGATCGATCG')
rev_comp = seq.reverse_complement()

print('Python workflow successful')
" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Python data science workflow${NC}"
    rm -f /tmp/volcano_test.png 2>/dev/null
else
    echo -e "${RED}❌ Python data science workflow${NC}"
    ((FAILED_ESSENTIAL++))
fi

# Test batch correction with sva
echo -n "Testing batch correction (sva)... "
if Rscript -e "
suppressMessages({
  library(sva)
  library(tidyverse)
  
  # Simulate expression data with batch effects
  n_genes <- 1000
  n_samples <- 20
  expr_data <- matrix(rnorm(n_genes * n_samples), nrow=n_genes)
  
  # Add batch effects
  batch <- c(rep(1, 10), rep(2, 10))
  batch_effect <- matrix(rnorm(n_genes * 2), nrow=n_genes)[, batch]
  expr_data <- expr_data + batch_effect
  
  # Create pheno data
  pheno <- data.frame(
    condition = factor(rep(c('ctrl', 'treat'), 10)),
    batch = factor(batch)
  )
  
  # Create model matrices
  mod <- model.matrix(~ condition, data=pheno)
  mod0 <- model.matrix(~ 1, data=pheno)
  
  # Estimate surrogate variables
  svobj <- sva(expr_data, mod, mod0, n.sv=2)
  
  cat('Batch correction successful\\n')
})" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ batch correction (sva)${NC}"
else
    echo -e "${RED}❌ batch correction (sva)${NC}"
    ((FAILED_ESSENTIAL++))
fi

# Test biomaRt functionality (may fail without internet)
echo -n "Testing biomaRt gene annotation... "
if Rscript -e "
suppressMessages({
  library(biomaRt)
  
  # Test basic functionality without internet connection
  # Just check if the package loads and basic functions exist
  if (exists('useMart') && exists('getBM')) {
    cat('biomaRt basic functions available\\n')
  } else {
    stop('biomaRt functions missing')
  }
})" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ biomaRt available${NC}"
else
    echo -e "${RED}❌ biomaRt not functional${NC}"
    ((FAILED_ESSENTIAL++))
fi

echo ""
echo "📋 Summary:"
echo "=========="

TOTAL_ESSENTIAL_FAILED=$FAILED_ESSENTIAL
TOTAL_OPTIONAL_FAILED=$FAILED_OPTIONAL

if [[ $TOTAL_ESSENTIAL_FAILED -eq 0 ]]; then
    echo -e "${GREEN}🎉 All essential tools are working perfectly!${NC}"
    echo "✅ Ready for nf-core/rnaseq pipeline execution"
    echo "✅ Ready for differential expression analysis"
    echo "✅ Ready for batch correction with sva"
    echo "✅ Ready for gene annotation with biomaRt"
    
    if [[ $TOTAL_OPTIONAL_FAILED -gt 0 ]]; then
        echo -e "${YELLOW}ℹ️  $TOTAL_OPTIONAL_FAILED optional tool(s) missing (functionality may be limited)${NC}"
    fi
    
    echo ""
    echo "🚀 Recommended workflow:"
    echo "1. Download SRA data: python scripts/sra_download.py --dataset all"
    echo "2. Create samplesheet: python scripts/create_samplesheet.py"  
    echo "3. Run nf-core/rnaseq: nextflow run nf-core/rnaseq -c nf-core/configs/salmon_config.conf"
    echo "4. Differential expression analysis with R (DESeq2)"
    echo "5. Batch correction with sva package"
    echo "6. Gene annotation with biomaRt"
    echo "7. Meta-analysis with metafor package"
    
else
    echo -e "${RED}⚠️  $TOTAL_ESSENTIAL_FAILED essential tool(s) failed!${NC}"
    echo -e "${YELLOW}Pipeline may not work correctly.${NC}"
    echo "Please install missing essential tools before proceeding."
    
    if [[ $TOTAL_OPTIONAL_FAILED -gt 0 ]]; then
        echo -e "${YELLOW}Additionally, $TOTAL_OPTIONAL_FAILED optional tool(s) are missing.${NC}"
    fi
fi

echo ""
echo "🔍 Environment Details:"
echo "======================"
echo "OS: $(uname -s) $(uname -r)"
echo "Architecture: $(uname -m)"
if command -v python >/dev/null 2>&1; then
    echo "Python: $(python --version 2>&1)"
fi
if command -v R >/dev/null 2>&1; then
    echo "R: $(R --version 2>&1 | head -1)"
fi
if command -v nextflow >/dev/null 2>&1; then
    echo "Nextflow: $(nextflow -version 2>&1 | head -1 | cut -d' ' -f3)"
fi
if command -v micromamba >/dev/null 2>&1; then
    echo "Micromamba: $(micromamba --version)"
fi

echo ""
echo "📦 Key Package Versions:"
python -c "
import sys
packages = ['pandas', 'numpy', 'matplotlib', 'Bio', 'sklearn']
for pkg in packages:
    try:
        module = __import__(pkg)
        version = getattr(module, '__version__', 'unknown')
        print(f'{pkg}: {version}')
    except ImportError:
        print(f'{pkg}: not available')
" 2>/dev/null

echo ""
echo "🧬 Comprehensive tool testing complete!"

# Exit with error code if essential tools failed
if [[ $TOTAL_ESSENTIAL_FAILED -gt 0 ]]; then
    exit 1
else
    exit 0
fi