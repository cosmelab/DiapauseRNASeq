# Diapause RNA-seq Analysis Environment

A comprehensive Docker-based environment for RNA-seq analysis of diapause studies, featuring differential expression analysis, quality control, and visualization tools.

## 🚀 Quick Start

### Using Docker Compose (Recommended)
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

## 🐳 Docker Image

The environment is available as a Docker image:
```bash
docker pull cosmelab/diapause-rnaseq:latest
```

## 📋 Features

### Bioinformatics Tools
- **RNA-seq Analysis**: STAR, Salmon, DESeq2
- **Quality Control**: FastQC, MultiQC, TrimGalore
- **Variant Calling**: bcftools, samtools, bedtools
- **Data Processing**: Python, R, Bash scripting

### Development Environment
- **Shell**: Zsh with Oh My Zsh and Powerlevel10k
- **Package Managers**: micromamba, pip, R
- **IDE Support**: Jupyter Lab, VS Code integration
- **Version Control**: Git with enhanced tooling

### Visualization & Analysis
- **Python**: matplotlib, seaborn, plotnine, bokeh
- **R**: ggplot2, pheatmap, EnhancedVolcano
- **Statistics**: DESeq2, tximport, metafor

## 📁 Project Structure

```
DiapauseRNASeq/
├── data/
│   ├── raw/           # Raw sequencing data
│   ├── metadata/      # Sample information
│   └── references/    # Genome references
├── scripts/
│   ├── differential_expression/  # DE analysis scripts
│   └── download/      # Data download utilities
├── output/            # Analysis results
├── logs/              # Log files
├── Dockerfile         # Container definition
├── docker-compose.yml # Multi-container setup
└── setup.sh          # Environment setup script
```

## 🔧 Configuration

### Environment Variables
- `R_LIBS_USER`: R package installation directory
- `LD_LIBRARY_PATH`: Library path for compiled tools
- `JUPYTER_CONFIG_DIR`: Jupyter configuration location

### Volume Mounts
- `./:/proj`: Project directory
- `rnaseq-data:/proj/data/raw`: Persistent data storage
- `sra-cache:/proj/data/sra`: SRA download cache

## 📊 Analysis Workflows

### 1. Data Download
```bash
# Download SRA data
python scripts/sra_download.py --dataset PRJNA158021 --output-dir data
```

### 2. Quality Control
```bash
# Run FastQC
fastqc data/raw/*.fastq.gz -o output/qc/

# Generate MultiQC report
multiqc output/qc/ -o output/qc/
```

### 3. Differential Expression
```bash
# Run DESeq2 analysis
Rscript scripts/differential_expression/de_analysis_PRJNA158021.R
```

## 🛠️ Development

### Adding New Tools
1. Update `Dockerfile` with new packages
2. Rebuild the image: `docker-compose build`
3. Test the new tools in the container

### Custom Scripts
- Place analysis scripts in `scripts/`
- Use relative paths from `/proj` working directory
- Follow the existing naming conventions

## 🔍 Quality Control

### Pre-processing
- Adapter trimming with TrimGalore
- Quality filtering
- Read length distribution analysis

### Post-alignment
- Mapping statistics
- Coverage analysis
- Duplicate detection

## 📈 Visualization

### Built-in Plots
- PCA plots for sample relationships
- Volcano plots for differential expression
- Heatmaps for gene expression patterns
- Quality control summaries

### Custom Visualizations
- Use Python plotting libraries (matplotlib, seaborn)
- R-based plots with ggplot2
- Interactive plots with bokeh

## 🚀 HPC Deployment

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

## 📚 Documentation

- [Analysis Best Practices](RNAseq_Analysis_Best_Practices.md)
- [Publication Plan](RNAseq_Publication_Plan.md)
- [Setup Guide](setup_guide.md)
- [HPC Configuration](hpcc_nfcore_install.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- RNA-seq analysis community
- Bioconductor project
- nf-core community
- Docker and containerization community

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/cosmelab/DiapauseRNASeq/issues)
- **Documentation**: Check the docs folder
- **Email**: degopwn@gmail.com

## 🔄 Version History

- **v1.0.0**: Initial release with basic RNA-seq analysis environment
- **v1.1.0**: Added HPC support and enhanced visualization tools
- **v1.2.0**: Integrated nf-core pipelines and improved documentation

---

**Maintainer**: [cosmelab](https://github.com/cosmelab)  
**Last Updated**: December 2024 