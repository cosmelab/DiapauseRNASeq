# AGENTS.md - Diapause RNA-seq Analysis Project Guide

## Project Overview

### Research Context
- **Species**: *Aedes albopictus* (Asian tiger mosquito)
- **Research Goal**: Validate GWAS candidate genes through differential expression analysis
- **Main Question**: Are genes identified in GWAS for diapause regulation differentially expressed between diapausing and non-diapausing conditions?
- **Publication Target**: This RNA-seq analysis supports a GWAS manuscript
- **Candidate Genes**: 34 GWAS-identified genes (LOC identifiers, list to be provided)

### Experimental Design Details
- **3 Independent Datasets** from different experiments, sequencing platforms, and life stages:

#### Dataset 1: PRJNA268379 (Adult Females - Huang et al. 2015)
- **Design**: 2×2 Factorial (Photoperiod × Blood meal)
- **Conditions**: 
  - Photoperiod: Long-day (LD, 16L:8D) vs Short-day (SD, 8L:16D)
  - Blood meal: Non-blood-fed (NBF) vs Blood-fed (BF)
- **Replicates**: 4 biological replicates per condition (16 total libraries)
- **Platform**: HiSeq2000

#### Dataset 2: PRJNA158021 (Embryos - Poelchau et al. 2013a)
- **Design**: Time course with diapause comparison
- **Timepoints**: 72-78h and 135-141h post-oviposition  
- **Conditions**: Diapause (D) vs Non-diapause (ND)
- **Focus**: Diapause preparation during embryonic development
- **Platform**: GAIIx

#### Dataset 3: PRJNA187045 (Pharate Larvae - Poelchau et al. 2013b)
- **Design**: Time course comparison
- **Timepoints**: 11, 21, and 40 days post-oviposition
- **Conditions**: Diapause (D) vs Quiescence (Q)  
- **Focus**: Diapause maintenance vs general dormancy
- **Platform**: HiSeq2000

### Sample Metadata Structure
Standard metadata table includes:
- `Dataset`: PRJNA268379, PRJNA158021, PRJNA187045
- `Life_Stage`: Adult, Embryo, Pharate_larvae
- `Condition`: NBF_LD, NBF_SD, BF_LD, BF_SD, D_72h, ND_72h, etc.
- `Timepoint`: Adult, 72h_pov, 135h_pov, 11d_pov, 21d_pov, 40d_pov
- `Photoperiod`: Long_day, Short_day
- `Blood_meal`: Unfed, Fed
- `Comparison_Group`: Non_diapause, Diapause_induction, Diapause_prep, Diapause_maintenance, Quiescence

### Technical Challenges
- **Cross-platform integration**: Different sequencing platforms (HiSeq2000, GAIIx)
- **Batch effects**: Essential correction for platform differences using ComBat-seq
- **Meta-analysis approach**: Combine evidence across life stages using metafor
- **Candidate gene focus**: Prioritize 34 GWAS-identified genes

## Quick Reference

### Dataset Summary
| Dataset | Life Stage | Conditions | Replicates | Platform | Key Comparison |
|---------|------------|------------|------------|----------|----------------|
| PRJNA268379 | Adult females | LD/SD × Unfed/Fed | 4 per condition (16 total) | HiSeq2000 | Short-day vs Long-day |
| PRJNA158021 | Embryos | D vs ND × 2 timepoints | 3 per condition | GAIIx | Diapause prep vs Non-diapause |
| PRJNA187045 | Pharate larvae | D vs Q × 3 timepoints | Variable | HiSeq2000 | Diapause vs Quiescence |

### Key Analysis Priorities
1. **High Priority**: GWAS candidate gene expression in all 3 datasets
2. **Medium Priority**: Cross-platform batch correction and meta-analysis
3. **Lower Priority**: Exploratory genome-wide differential expression

### Candidate Genes
- **Total**: 34 GWAS-identified genes with LOC identifiers
- **Format**: LOC109397825, LOC109405370, LOC109398973, etc.
- **Focus**: Prioritize these genes in all analyses before genome-wide exploration

## AI Assistant Guidelines
Before creating new scripts, check if there are scripts with the same name already. If there are, do not overwrite them.

- Always rely on explicit user requests
- If uncertain, ask clarifying questions instead of making assumptions
- When dealing with technical parameters or file paths, confirm details rather than inferring

### 2. Provide Direct Answers
- Respond to user questions concisely and directly
- Avoid unnecessary elaboration or unrelated information
- Focus on the specific question asked

### 3. Propose Changes with Permission
- If suggesting modifications or additional steps, explicitly ask for user approval first
- Example: "Would you like me to propose a change to this section?"
- Do not implement changes without explicit confirmation

### 4. Be Practical and Efficient
- Focus on the user's immediate need
- Use the simplest approach that satisfies the request
- Prioritize working solutions over theoretical perfection

## Computing Environment

### Docker Strategy
- **Dual deployment**: Same container runs on laptop AND HPC
- **Container includes**: R, Python, RNA-seq tools (STAR, salmon, DESeq2, sva, metafor)
- **Data persistence**: Bind mounts for data/ and output/ directories
- **Jupyter integration**: Port 8888 for interactive analysis

### Directory Structure
```
DiapauseRNASeq/
├── data/
│   ├── raw/           # FASTQ files by dataset (PRJNA*)
│   ├── metadata/      # Sample information and candidate genes
│   └── references/    # Genome and annotation files
├── results/
│   ├── organized/     # Organized output from HPC
│   │   ├── gene_counts/      # Gene-level count matrices
│   │   ├── gene_tpm/         # Gene-level TPM values
│   │   ├── transcript_counts/ # Transcript-level counts
│   │   ├── transcript_tpm/    # Transcript-level TPM values
│   │   ├── qc_reports/       # Quality control reports
│   │   ├── alignment_stats/   # Alignment statistics
│   │   ├── featurecounts/    # FeatureCounts results
│   │   └── multiqc/          # MultiQC reports
│   └── analysis/     # Local analysis results
│       ├── differential_expression/ # DESeq2 results
│       └── visualization/     # Plots and figures
├── scripts/
│   ├── analysis/     # Analysis scripts
│   └── visualization/ # Plotting scripts
└── logs/            # Analysis logs
```

## Analysis Workflow & Specific Models

### 1. Data Acquisition (Implemented)
- **Python scripts**: `sra_download.py`, `info_sra_checker.py`
- **Approach**: Parallel downloads with error handling
- **Validation**: Check file integrity and completeness
- **Metadata**: Generate sample information tables

### 2. Quality Control (Next Phase)
- **Tools**: FastQC, MultiQC
- **Focus**: Adapter contamination, quality scores, library complexity
- **Platform comparison**: Identify batch effects early

### 3. Quantification (Next Phase)
- **Alignment**: STAR or salmon (pseudo-alignment)
- **Reference**: *Aedes albopictus* genome
- **Output**: Gene-level counts/TPM for downstream analysis

### 4. Differential Expression (Core Analysis)

#### Specific DESeq2 Models:

**Adults (PRJNA268379):**
```r
# Model 1: Main effect of photoperiod (diapause induction)
dds <- DESeqDataSetFromTximport(txi, colData = metadata, 
                               design = ~ blood_meal + photoperiod)
results_adults <- results(dds, contrast = c("photoperiod", "Short_day", "Long_day"))

# Model 2: Blood meal interaction
dds_interaction <- DESeqDataSetFromTximport(txi, colData = metadata, 
                                          design = ~ photoperiod * blood_meal)
results_interaction <- results(dds_interaction, name = "photoperiodShort_day.blood_mealBlood_fed")
```

**Embryos (PRJNA158021):**
```r
# Model: Diapause preparation
dds_embryo <- DESeqDataSetFromTximport(txi, colData = metadata, 
                                      design = ~ timepoint + condition)
results_embryo <- results(dds_embryo, contrast = c("condition", "Diapause", "Non_diapause"))

# Time-specific contrasts
results_72h <- results(dds_embryo, contrast = list("condition_Diapause_vs_Non_diapause", 
                                                  "timepoint72h.conditionDiapause"))
```

**Pharate Larvae (PRJNA187045):**
```r
# Model: Diapause maintenance vs quiescence  
dds_pharate <- DESeqDataSetFromTximport(txi, colData = metadata, 
                                       design = ~ timepoint + condition)
results_pharate <- results(dds_pharate, contrast = c("condition", "Diapause", "Quiescence"))

# Time course analysis
dds_timecourse <- DESeqDataSetFromTximport(txi, colData = metadata, 
                                          design = ~ condition * timepoint)
```

### 5. Cross-Platform Integration Strategy

#### Step 1: Individual Dataset Analysis
```r
# Extract results for candidate genes
candidate_genes <- c("LOC109397825", "LOC109405370", "LOC109398973", 
                    "LOC109397812", "LOC109405365", ...) # 34 total genes

extract_candidates <- function(results_obj, gene_list) {
  results_df <- as.data.frame(results_obj)
  results_df$gene_id <- rownames(results_df)
  return(results_df[results_df$gene_id %in% gene_list, ])
}
```

#### Step 2: Cross-Platform Normalization
```r
library(sva)

# Combine TPM data across datasets
tpm_combined <- cbind(tpm_adults, tpm_embryos, tpm_pharate)
metadata_combined <- rbind(meta_adults, meta_embryos, meta_pharate)

# Add platform batch variable
metadata_combined$platform <- c(rep("HiSeq2000", nrow(meta_adults)),
                                rep("GAIIx", nrow(meta_embryos)), 
                                rep("HiSeq2000", nrow(meta_pharate)))

# ComBat-seq batch correction
tpm_corrected <- ComBat_seq(tpm_combined, 
                           batch = metadata_combined$platform,
                           group = metadata_combined$diapause_status)
```

#### Step 3: Meta-Analysis 
```r
library(metafor)

# Combine effect sizes across life stages for each gene
combine_effects <- function(gene_id) {
  # Extract log2FC and SE from each dataset
  adult_effect <- results_adults[gene_id, "log2FoldChange"]
  adult_se <- results_adults[gene_id, "lfcSE"]
  
  embryo_effect <- results_embryo[gene_id, "log2FoldChange"] 
  embryo_se <- results_embryo[gene_id, "lfcSE"]
  
  pharate_effect <- results_pharate[gene_id, "log2FoldChange"]
  pharate_se <- results_pharate[gene_id, "lfcSE"]
  
  # Fixed-effects meta-analysis
  meta_result <- rma(yi = c(adult_effect, embryo_effect, pharate_effect),
                     sei = c(adult_se, embryo_se, pharate_se),
                     method = "FE")
  
  return(meta_result)
}
```

### 6. Expected Outputs

#### For Each Candidate Gene:
- Log2 fold change in each life stage
- Statistical significance (adjusted p-value)
- Direction of effect consistency across datasets
- Meta-analysis combined effect size and p-value
- Platform-corrected expression levels (TPM)

#### Summary Deliverables:
1. **Candidate gene expression matrix** (TPM values across all samples)
2. **Differential expression results** (log2FC, p-values for each comparison)
3. **Meta-analysis summary** (combined effects across life stages)
4. **Gene prioritization ranking** (based on consistency + significance)

## Code Preferences

### Language Usage
- **Python**: Data processing, file handling, pipeline orchestration, visualization
- **R**: Statistics, DESeq2, sva (ComBat-seq), metafor
- **Shell/Bash**: Bioinformatics tools, file management

### Code Style
- **Documentation**: Comprehensive docstrings and comments
- **Logging**: Use logging module for progress tracking
- **Error handling**: Robust exception handling with graceful failures
- **Reproducibility**: Version control, container versions, random seeds
- **Modularity**: Separate scripts for each analysis step

### File Naming Conventions
- **Scripts**: `verb_noun.py` (e.g., `download_sra.py`, `quantify_genes.py`)
- **Output**: Include date/version in filenames
- **Logs**: Match script names (e.g., `sra_download.log`)

## Code Standards

### Documentation Requirements
- **Script headers**: Include purpose, usage, dependencies, and example
- **Function docstrings**: Use NumPy style with parameters, returns, and examples
- **Comments**: Explain complex logic and biological context
- **Logging**: Use Python logging module for progress tracking

### Code Quality
- **Error handling**: Robust exception handling with graceful failures
- **Reproducibility**: Set random seeds, document versions
- **Modularity**: Separate scripts for each analysis step
- **Path handling**: Use relative paths and Path objects

### Publication Preparation
- **Remove personal information**: File paths, usernames, emails, API keys
- **Use configuration files**: Environment variables for system-specific settings
- **Version pinning**: Exact package versions in requirements.txt
- **Documentation**: Complete README with installation and usage instructions

### Sample Description Standardization

#### Consistent Naming Convention:
All sample descriptions should follow standardized, publication-ready formats:

**Adults (PRJNA268379):**
```python
# Example: "ld_nb_4" becomes:
"Ae. albopictus females under long-day conditions, non-blood-fed, biological replicate 4"
```

**Embryos (PRJNA158021):**
```python  
# Example: "ndi_135_rep3" becomes:
"Ae. albopictus reared under non-diapause-inducing (NDI) conditions, embryos 135-141h post-oviposition, biological replicate 3"
```

**Pharate Larvae (PRJNA187045):**
```python
# Example: "nd_40d_rep4" becomes:
"Ae. albopictus ND 40d pharate larvae, biological replicate 4"
```

#### Implementation Pattern:
- **Use generation functions**: Create consistent descriptions programmatically
- **Full species names**: Always use *Ae. albopictus* (italicized in publications)
- **Biological context**: Include photoperiod, timepoint, and treatment details
- **Standard terminology**: "biological replicate" instead of "rep"
- **Cross-dataset consistency**: Uniform format across all three datasets

## Common Tasks & Patterns

### Starting a New Analysis
1. Check existing data in `data/` directory
2. Review metadata and sample information
3. Create new script in appropriate `scripts/` subdirectory
4. Focus on candidate genes first, then expand if needed
5. Test with small subset before full run

### Working with Candidate Genes
- Always filter results to focus on the 34 candidate genes first
- Use consistent extraction patterns across datasets
- Check for consistent effect directions across life stages
- Prioritize genes significant in multiple datasets

### Cross-Platform Analysis
- Apply ComBat-seq batch correction before combining datasets
- Use fixed-effects meta-analysis for combining effect sizes
- Validate batch correction with PCA plots
- Document platform-specific patterns

## Key Technical Details

### SRA Download Strategy
- **Prefetch + fastq-dump**: Two-step process for reliability
- **Parallel processing**: ThreadPoolExecutor for multiple downloads
- **Cache management**: Separate SRA cache directory
- **Resume capability**: Skip existing files
- **Test mode**: Small subset for development

### Statistical Analysis Priorities
1. **Primary Question**: Are GWAS candidate genes differentially expressed?
2. **Main Contrasts**:
   - Adults: Short-day vs Long-day (diapause induction)
   - Embryos: Diapause preparation vs Non-diapause development  
   - Pharate larvae: Diapause maintenance vs Quiescence
3. **Secondary Questions**:
   - Consistency across life stages
   - Platform robustness after batch correction
   - Blood meal interaction effects

### GWAS Integration
- **Candidate gene list**: 34 LOC identifiers from GWAS results
- **Priority analysis**: Focus statistical power on candidate genes
- **Effect direction**: Assess consistency of up/down regulation across life stages
- **Validation criteria**: Significance in multiple datasets strengthens evidence

## Communication Guidelines

### What to Include in Progress Reports
- **Files processed**: Number and size of input files
- **Quality metrics**: Read counts, alignment rates, gene detection
- **Statistical results**: Number of DE genes, effect sizes for candidates
- **Cross-platform consistency**: Batch correction effectiveness
- **Issues encountered**: Failed samples, quality concerns
- **Next steps**: Clear action items

### When to Ask for Clarification
- **GWAS gene list**: When the full 34 candidate gene list is needed
- **Analysis parameters**: Significance thresholds, model specifications
- **Result interpretation**: Biological significance of findings
- **Publication requirements**: Specific figures or tables needed

## Troubleshooting Common Issues

### Data Download Problems
- **Network timeouts**: Increase timeout values, retry failed downloads
- **SRA toolkit errors**: Check tool versions, clear cache
- **Disk space**: Monitor available space, clean up intermediate files

### Analysis Issues
- **Memory errors**: Increase container resources, process in batches
- **Platform differences**: Apply ComBat-seq, check for residual batch effects
- **Low statistical power**: Focus on candidate genes, use meta-analysis
- **Convergence issues**: Check DESeq2 model specifications, remove outliers

### Container Issues
- **Port conflicts**: Use different ports for multiple instances
- **File permissions**: Use proper user mapping in Docker
- **Path problems**: Use absolute paths for mounted volumes
- **R package conflicts**: Document specific versions in Dockerfile

## Research Context Notes

### Diapause Biology
- **Photoperiod response**: Short days (8L:16D) induce diapause preparation
- **Life stage specificity**: Different mechanisms at adult, embryo, pharate larval stages
- **Metabolic changes**: Energy storage, stress resistance, developmental arrest
- **Molecular regulation**: Hormone signaling, circadian rhythms, stress response

### GWAS Context
- **Population genetics**: Natural variation in diapause timing across populations
- **Quantitative trait**: Continuous variation in diapause propensity  
- **Candidate genes**: 34 genes identified through genome-wide association
- **Functional validation**: Expression analysis confirms biological relevance
- **Cross-validation**: Multiple life stages provide independent validation

This guide provides comprehensive context for AI assistants working on this sophisticated cross-platform RNA-seq analysis. The specific models and approaches are based on the detailed analysis design in `de_analysis_design_repo.md`. 