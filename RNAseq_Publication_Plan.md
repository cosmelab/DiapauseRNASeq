# RNA-seq Analysis and Publication Plan

## 1. Data Organization

### 1.1 Project Structure
```
.
├── data/
│   ├── raw/                    # FASTQ files by dataset
│   ├── metadata/              # Sample information and candidate genes
│   └── references/            # Genome and annotation files
├── results/
│   ├── organized/             # Organized output from HPC
│   │   ├── gene_counts/      # Gene-level count matrices
│   │   ├── gene_tpm/         # Gene-level TPM values
│   │   ├── transcript_counts/ # Transcript-level counts
│   │   ├── transcript_tpm/    # Transcript-level TPM values
│   │   ├── qc_reports/       # Quality control reports
│   │   ├── alignment_stats/   # Alignment statistics
│   │   ├── featurecounts/    # FeatureCounts results
│   │   └── multiqc/          # MultiQC reports
│   └── analysis/             # Local analysis results
│       ├── differential_expression/ # DESeq2 results
│       └── visualization/     # Plots and figures
├── scripts/
│   ├── analysis/             # Analysis scripts
│   └── visualization/        # Plotting scripts
└── logs/                     # Log files
```

### 1.2 Required Files for Each Project
- [x] Raw gene counts matrix (from star_salmon/salmon.merged.gene_counts.tsv)
- [x] Normalized expression values (from star_salmon/salmon.merged.gene_tpm.tsv)
- [x] Sample metadata (PRJNA*_metadata.csv)
- [x] QC reports (FastQC, MultiQC, Qualimap, RSeQC)
- [x] Alignment statistics (STAR logs)

## 2. Quality Control Requirements

### 2.1 Raw Data Quality
- [x] FastQC reports for each sample
- [x] MultiQC summary report
- [x] Read quality metrics
  - [x] Per base sequence quality
  - [x] Per sequence quality scores
  - [x] Per base sequence content
  - [x] GC content distribution
  - [x] Sequence duplication levels
  - [x] Overrepresented sequences

### 2.2 Alignment Statistics
- [x] STAR alignment rates
- [x] Qualimap reports
  - [x] Mapping rates
  - [x] Coverage distribution
  - [x] Gene body coverage
  - [x] 5' to 3' bias
- [x] RSeQC reports
  - [x] Read distribution across gene bodies
  - [x] Junction saturation analysis
  - [x] Insert size distribution

### 2.3 Expression Analysis
- [ ] PCA plot of all samples
- [ ] Sample correlation heatmap
- [ ] MA plots for differential expression
- [ ] Volcano plots for significant genes
- [ ] Gene counts distribution

## 3. Publication Requirements

### 3.1 Main Text
- [ ] Methods section
  - [x] Alignment rates (from STAR logs)
  - [x] Number of mapped reads per sample
  - [x] Number of detected genes
  - [x] Quality thresholds used
  - [ ] Normalization method used
  - [ ] Statistical tests performed

### 3.2 Supplemental Files
- [x] Tables
  - [x] Raw gene counts matrix
  - [x] Normalized expression values (TPM)
  - [ ] List of differentially expressed genes
    - [ ] Log2 fold changes
    - [ ] P-values
    - [ ] Adjusted P-values
    - [ ] Gene annotations
- [x] QC Reports
  - [x] MultiQC HTML report
  - [x] Qualimap reports
  - [x] RSeQC reports

## 4. Analysis Workflow

### 4.1 HPC Phase (Completed)
1. [x] Run RNA-seq pipeline
2. [x] Organize outputs by project
3. [x] Collect QC metrics
4. [x] Generate initial QC plots
5. [x] Download organized data to local machine

### 4.2 Local Analysis Phase
1. [x] Set up R environment in Docker
2. [ ] Load and preprocess data
   - [ ] Create R script for data loading
   - [ ] Implement quality filters
   - [ ] Normalize data
3. [ ] Perform differential expression analysis
   - [ ] DESeq2 analysis
   - [ ] Batch effect correction (if needed)
   - [ ] Statistical testing
4. [ ] Generate publication-quality plots
   - [ ] PCA plots
   - [ ] Heatmaps
   - [ ] Volcano plots
   - [ ] MA plots
5. [ ] Create summary tables
   - [ ] DEG lists
   - [ ] Gene annotations
   - [ ] Statistics summary
6. [ ] Write analysis scripts
   - [ ] Main analysis script
   - [ ] Visualization functions
   - [ ] Helper utilities

## 5. Next Steps

### 5.1 Immediate Actions
1. [x] Modify organize_outputs.sh to include all required files
2. [x] Create script to generate QC summary tables
3. [x] Set up Docker container for local analysis
4. [ ] Create R scripts for analysis
   - [ ] data_loading.R
   - [ ] differential_expression.R
   - [ ] visualization.R
   - [ ] utils.R

### 5.2 Future Tasks
1. [ ] Differential expression analysis
   - [ ] Identify DEGs
   - [ ] Functional enrichment
   - [ ] Pathway analysis
2. [ ] Generate publication figures
   - [ ] Main figures
   - [ ] Supplemental figures
3. [ ] Write analysis documentation
   - [ ] Methods section
   - [ ] Results section
   - [ ] Figure legends

## 6. Notes
- [x] Keep all scripts and parameters for reproducibility
- [ ] Document any filtering steps
- [ ] Save intermediate results
- [x] Use version control for analysis scripts
- [ ] Create README files for each analysis step

## 7. Docker Environment
- Base image: rocker/tidyverse:4.3.2
- R packages:
  - DESeq2, tximport, AnnotationDbi, biomaRt, sva, edgeR, limma
  - tidyverse, here, data.table, metafor
- Python packages:
  - bokeh, altair, holoviews
  - pandas, numpy, scipy, matplotlib, seaborn 