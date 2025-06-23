#!/bin/bash

echo "Checking availability of packages we're installing in Dockerfile..."
echo "=================================================="

# List of packages we're actually installing
packages=(
    # R and Bioconductor packages
    "r-base"
    "bioconductor-deseq2"
    "bioconductor-tximport"
    "bioconductor-annotationdbi"
    "bioconductor-biomart"
    "bioconductor-sva"
    
    # Bioinformatics tools
    "bcftools"
    "samtools"
    "bedtools"
    "tabix"
    "vcftools"
    
    # Data access tools
    "sra-tools"
    "entrez-direct"
    
    # Java
    "openjdk"
)

echo "Searching conda-forge and bioconda channels..."
echo ""

for package in "${packages[@]}"; do
    echo "Checking: $package"
    # Check if package exists in conda channels
    if micromamba search -c conda-forge -c bioconda "$package" &>/dev/null; then
        echo "  ✅ FOUND in conda channels"
    else
        echo "  ❌ NOT FOUND in conda channels"
    fi
    echo ""
done

echo "=================================================="
echo "These are the packages we're actually installing in the Dockerfile"
echo "If any show ❌, we need to fix the Dockerfile before building" 