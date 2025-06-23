#!/bin/bash

echo "🧬 Testing nf-core/rnaseq Analysis Tools"
echo "========================================"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

test_tool() {
    local tool=$1
    local test_cmd=$2
    
    if eval "$test_cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $tool${NC}"
        return 0
    else
        echo -e "${RED}❌ $tool${NC}"
        return 1
    fi
}

# Track failed tests
FAILED_TESTS=0

echo "🔧 Essential Pipeline Tools:"
test_tool "nextflow" "nextflow -version" || ((FAILED_TESTS++))
test_tool "salmon" "salmon --version" || ((FAILED_TESTS++))
test_tool "fastp" "fastp --version" || ((FAILED_TESTS++))
test_tool "fastqc" "fastqc --version" || ((FAILED_TESTS++))
test_tool "multiqc" "multiqc --version" || ((FAILED_TESTS++))
test_tool "samtools" "samtools --version" || ((FAILED_TESTS++))
test_tool "bedtools" "bedtools --version" || ((FAILED_TESTS++))

echo ""
echo "📥 Data Download Tools:"
test_tool "fastq-dump" "fastq-dump --version"
test_tool "prefetch" "prefetch --version"
test_tool "vdb-config" "vdb-config --version"
test_tool "esearch" "esearch -version"
test_tool "efetch" "efetch -help"

echo ""
echo "🐍 Python Environment:"
test_tool "pandas" "python -c 'import pandas'" || ((FAILED_TESTS++))
test_tool "numpy" "python -c 'import numpy'" || ((FAILED_TESTS++))
test_tool "matplotlib" "python -c 'import matplotlib'" || ((FAILED_TESTS++))
test_tool "seaborn" "python -c 'import seaborn'"
test_tool "biopython" "python -c 'import Bio'" || ((FAILED_TESTS++))

echo ""
echo "📈 Essential R Packages:"
test_tool "DESeq2" "Rscript -e 'library(DESeq2)'" || ((FAILED_TESTS++))
test_tool "tximport" "Rscript -e 'library(tximport)'" || ((FAILED_TESTS++))
test_tool "tidyverse" "Rscript -e 'library(tidyverse)'" || ((FAILED_TESTS++))
test_tool "metafor" "Rscript -e 'library(metafor)'" || ((FAILED_TESTS++))
test_tool "here" "Rscript -e 'library(here)'" || ((FAILED_TESTS++))
test_tool "data.table" "Rscript -e 'library(data.table)'" || ((FAILED_TESTS++))

echo ""
echo "🧪 Working R/Bioconductor Packages:"
test_tool "sva" "Rscript -e 'library(sva)'"
test_tool "edgeR" "Rscript -e 'library(edgeR)'"
test_tool "limma" "Rscript -e 'library(limma)'"
test_tool "AnnotationDbi" "Rscript -e 'library(AnnotationDbi)'"
test_tool "biomaRt" "Rscript -e 'library(biomaRt)'"

echo ""
echo "📁 File I/O R Packages:"
test_tool "readr" "Rscript -e 'library(readr)'"
test_tool "readxl" "Rscript -e 'library(readxl)'"
test_tool "writexl" "Rscript -e 'library(writexl)'"

echo ""
echo "🚀 Functional Tests:"

# Test salmon with dummy data
echo -n "Testing salmon functionality... "
if echo -e ">test\nATCGATCG" | salmon index -t /dev/stdin -i test_index -k 7 >/dev/null 2>&1; then
    echo -e "${GREEN}✅ salmon functional${NC}"
    rm -rf test_index 2>/dev/null
else
    echo -e "${RED}❌ salmon functional${NC}"
    ((FAILED_TESTS++))
fi

# Test R statistical functionality
echo -n "Testing R statistical functions... "
if Rscript -e "
suppressMessages({
  library(DESeq2)
  library(tximport)
  # Create dummy data
  counts <- matrix(rpois(200, 10), ncol=4)
  colData <- data.frame(condition=factor(rep(c('A','B'), each=2)))
  dds <- DESeqDataSetFromMatrix(counts, colData, design = ~ condition)
  cat('R statistical functions work\n')
})" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ R statistical functions${NC}"
else
    echo -e "${RED}❌ R statistical functions${NC}"
    ((FAILED_TESTS++))
fi

# Test Python data science functionality
echo -n "Testing Python data science... "
if python -c "
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
df = pd.DataFrame({'x': np.random.randn(10), 'y': np.random.randn(10)})
print('Python data science works')
" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Python data science${NC}"
else
    echo -e "${RED}❌ Python data science${NC}"
    ((FAILED_TESTS++))
fi

echo ""
echo "📋 Summary:"
echo "=========="

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 All essential tools are working perfectly!${NC}"
    echo "✅ Ready for nf-core/rnaseq pipeline execution"
    echo "✅ Ready for GWAS candidate gene analysis"
    echo ""
    echo "Next steps:"
    echo "1. Download SRA data: python scripts/sra_download.py --dataset all"
    echo "2. Run nf-core/rnaseq pipeline"
    echo "3. Perform differential expression analysis with R"
else
    echo -e "${RED}⚠️  $FAILED_TESTS essential tool(s) failed!${NC}"
    echo -e "${YELLOW}Pipeline may not work correctly.${NC}"
    echo "Please check the failed tools above."
fi

echo ""
echo -e "${GREEN}💡 Analysis Approach:${NC}"
echo "• Batch correction: sva package (ComBat method)"
echo "• Gene annotation: biomaRt package + local annotation files"
echo "• Differential expression: DESeq2 package"
echo "• Meta-analysis: metafor package"

echo ""
echo "🔍 Environment Info:"
echo "==================="
echo "OS: $(uname -s) $(uname -r)"
echo "Architecture: $(uname -m)"
if command -v python >/dev/null 2>&1; then
    echo "Python: $(python --version 2>&1)"
fi
if command -v R >/dev/null 2>&1; then
    echo "R: $(R --version 2>&1 | head -1)"
fi
if command -v nextflow >/dev/null 2>&1; then
    echo "Nextflow: $(nextflow -version 2>&1 | head -1)"
fi

echo ""
echo "🧬 Tool testing complete!"