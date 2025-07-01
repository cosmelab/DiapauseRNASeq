# Diapause RNA-seq Analysis Project

## ⚠️ **IMPORTANT: AI Assistant Rules**

**BEFORE responding to any request, the AI assistant MUST:**

1. Read USER_RULES.md completely
2. Follow the exact format specified there
3. Never make changes without permission
4. Always ask for confirmation before modifications

---

A comprehensive RNA-seq analysis pipeline for validating GWAS candidate genes in *Aedes albopictus* diapause regulation across multiple life stages and experimental conditions.

## 🎯 **Project Overview**

### Research Goal

Validate 34 GWAS-identified candidate genes through differential expression analysis across three independent RNA-seq datasets representing different life stages of diapause regulation.

### Datasets

- **PRJNA268379**: Adult females (photoperiod × blood meal factorial design)
- **PRJNA158021**: Embryos (diapause preparation time course)
- **PRJNA187045**: Pharate larvae (diapause vs quiescence comparison)

### Key Features

- **Cross-platform integration**: HiSeq2000 and GAIIx platforms
- **Multi-stage analysis**: Adult, embryo, and pharate larval stages
- **Batch correction**: ComBat-seq for platform effects
- **Meta-analysis**: Fixed-effects combination across datasets
- **Candidate gene focus**: Prioritized analysis of 34 GWAS genes

## 🚀 **Quick Start**

### Using Docker (Recommended)

```bash
# Clone the repository
git clone https://github.com/cosmelab/DiapauseRNASeq.git
cd DiapauseRNASeq

# Build and start the environment
docker-compose up -d

# Access Jupyter Lab
# Open http://localhost:8888 in your browser
```

### Using Docker directly

```bash
# Build the image
docker build -t diapause-rnaseq .

# Run the container
docker run -it -p 8888:8888 -v $(pwd):/proj diapause-rnaseq
```

## 📚 **Documentation**

### Core Documentation

- **[PROJECT_RULES.md](PROJECT_RULES.md)**: Analysis strategy, statistical models, and project rules
- **[WORKFLOW.md](WORKFLOW.md)**: Step-by-step pipeline instructions
- **[USER_RULES.md](USER_RULES.md)**: AI assistant guidelines and transparency rules

### Additional Resources

- **[RNAseq_Analysis_Best_Practices.md](RNAseq_Analysis_Best_Practices.md)**: Best practices for RNA-seq analysis
- **[RNAseq_Publication_Plan.md](RNAseq_Publication_Plan.md)**: Publication strategy and figure planning
- **[setup_guide.md](setup_guide.md)**: Environment setup instructions
- **[hpcc_nfcore_install.md](hpcc_nfcore_install.md)**: HPC configuration guide

## 🏗️ **Project Structure**

```
DiapauseRNASeq/
├── data/
│   ├── raw/           # FASTQ files by dataset (PRJNA*)
│   ├── metadata/      # Sample information and candidate genes
│   └── references/    # Genome and annotation files
├── results/
│   ├── organized/     # Organized output from HPC
│   └── analysis/      # Local analysis results
├── scripts/
│   ├── analysis/      # Analysis scripts
│   ├── differential_expression/  # DESeq2 analysis scripts
│   ├── download/      # Data download utilities
│   └── visualization/ # Plotting scripts
├── nf-core/
│   └── configs/       # HPC configuration files
├── Dockerfile         # Container definition
├── docker-compose.yml # Multi-container setup
└── setup.sh          # Environment setup script
```

## 🔬 **Analysis Pipeline**

### 1. Data Acquisition

```bash
# Download SRA datasets
python scripts/sra_download.py --accession PRJNA268379 --output data/raw/PRJNA268379
python scripts/sra_download.py --accession PRJNA158021 --output data/raw/PRJNA158021
python scripts/sra_download.py --accession PRJNA187045 --output data/raw/PRJNA187045
```

### 2. HPC Processing

```bash
# Run nf-core/rnaseq with Salmon quantification
nextflow run nf-core/rnaseq -profile hpc_batch --aligner salmon
```

### 3. Differential Expression

```bash
# Run DESeq2 analysis for each dataset
Rscript scripts/differential_expression/PRJNA268379_adult_females_Angela_DESeq.R
Rscript scripts/differential_expression/PRJNA158021_embryos_Mackenzie_DESeq.R
Rscript scripts/differential_expression/PRJNA187045_pharate_larvae_Sarah_DESeq.R
```

### 4. Cross-Platform Integration

```r
# Apply ComBat-seq batch correction
tpm_corrected <- ComBat_seq(tpm_combined, batch = platform, group = diapause_status)

# Perform meta-analysis
meta_results <- lapply(candidate_genes, combine_effects)
```

## 🐳 **Docker Environment**

### Available Tools

- **RNA-seq Analysis**: Salmon, DESeq2, tximport
- **Quality Control**: FastQC, MultiQC
- **Statistics**: R with DESeq2, sva, metafor
- **Data Processing**: Python, Bash scripting
- **Development**: Jupyter Lab, VS Code integration

### Docker Image

```bash
# Pull from Docker Hub
docker pull cosmelab/diapause-rnaseq:latest

# Multi-architecture support (amd64, arm64)
docker pull cosmelab/diapause-rnaseq:latest
```

## 🖥️ **HPC Deployment**

### Singularity/Apptainer

```bash
# Convert Docker image to Singularity
singularity pull docker://cosmelab/diapause-rnaseq:latest

# Run on HPC
singularity exec diapause-rnaseq.sif bash
```

### SLURM Integration

- Use `nf-core/configs/hpc_batch.conf` for Nextflow
- Configure resource limits in `custom.config`
- Submit jobs with appropriate resource requests

## 📊 **Expected Results**

### Key Deliverables

1. **Candidate gene expression matrix** (TPM values across all samples)
2. **Differential expression results** (log2FC, p-values for each comparison)
3. **Meta-analysis summary** (combined effects across life stages)
4. **Gene prioritization ranking** (based on consistency + significance)

### Quality Metrics

- **Alignment rates**: >80% for each dataset
- **Gene detection**: >10,000 genes per sample
- **Differential expression**: FDR < 0.05 for candidate genes
- **Batch correction**: PCA shows reduced platform separation

## 🔍 **Quality Control**

### Pre-processing

- Adapter trimming with TrimGalore
- Quality filtering
- Read length distribution analysis

### Post-alignment

- Mapping statistics
- Coverage analysis
- Duplicate detection

## 📈 **Visualization**

### Built-in Plots

- PCA plots for sample relationships
- Volcano plots for differential expression
- Heatmaps for gene expression patterns
- Quality control summaries

### Custom Visualizations

- Use Python plotting libraries (matplotlib, seaborn)
- R-based plots with ggplot2
- Interactive plots with bokeh

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 **Acknowledgments**

- RNA-seq analysis community
- Bioconductor project
- nf-core community
- Docker and containerization community

## 📞 **Support**

- **Issues**: [GitHub Issues](https://github.com/cosmelab/DiapauseRNASeq/issues)
- **Documentation**: Check the documentation files above
- **Email**: <degopwn@gmail.com>

## 🔄 **Version History**

- **v1.0.0**: Initial release with basic RNA-seq analysis environment
- **v1.1.0**: Added HPC support and enhanced visualization tools
- **v1.2.0**: Integrated nf-core pipelines and improved documentation
- **v1.3.0**: Multi-architecture Docker support and consolidated documentation

---

**Last Updated:** [Current Date]
**Project:** DiapauseRNASeq Analysis
**Purpose:** GWAS candidate gene validation through RNA-seq analysis
# Updated to use main branch and latest tags
