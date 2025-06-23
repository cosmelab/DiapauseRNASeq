# SRA Download Guide

## Overview
This guide explains how to download RNA-seq data from SRA for the diapause analysis project.

## Datasets
- **PRJNA268379**: Adult females (16 samples) - photoperiod and blood meal experiment
- **PRJNA158021**: Embryos (12 samples) - diapause preparation
- **PRJNA187045**: Pharate larvae (17 samples) - diapause maintenance vs quiescence

## Directory Structure

The script uses the following directory structure:
```
data/
├── raw/                    # FASTQ files go here
│   ├── PRJNA268379/       # Adult females FASTQ files
│   ├── PRJNA158021/       # Embryos FASTQ files  
│   └── PRJNA187045/       # Pharate larvae FASTQ files
├── metadata/              # Sample information and candidate genes
└── references/            # Genome and annotation files
```

**Important**: 
- **FASTQ files** are stored in `data/raw/DATASET_ID/` (these are the files you need for analysis)
- **Sample metadata** is stored in `data/metadata/` as JSON and CSV files
- **Reference files** are stored in `data/references/`

## Prerequisites

1. **SRA Toolkit** must be installed and configured
2. **Directory structure** from `setup.sh` must exist
3. **Internet connection** for downloading from NCBI

## Usage

### Basic Commands

```bash
# Test download (recommended first)
python scripts/sra_download.py --dataset PRJNA268379 --test

# Download one dataset
python scripts/sra_download.py --dataset PRJNA268379

# Download all datasets
python scripts/sra_download.py --dataset all
```

### Command Options

| Option | Description | Default |
|--------|-------------|---------|
| `--dataset` | Which dataset to download: `PRJNA268379`, `PRJNA158021`, `PRJNA187045`, or `all` | `all` |
| `--test` | Test mode: downloads only first 2 samples with 100 reads each | `False` |
| `--output-dir` | Base output directory | `data` |
| `--max-workers` | Number of parallel downloads (not used in current version) | `4` |

### Examples

```bash
# Test with small files first
python scripts/sra_download.py --dataset PRJNA268379 --test

# Download adult females dataset
python scripts/sra_download.py --dataset PRJNA268379

# Download embryos dataset
python scripts/sra_download.py --dataset PRJNA158021

# Download pharate larvae dataset
python scripts/sra_download.py --dataset PRJNA187045

# Download everything
python scripts/sra_download.py
```

## What the Script Does

### Step 1: Configuration
- Checks if SRA toolkit is available
- Configures SRA cache to use `data/sra/` directory
- Verifies output directories exist

### Step 2: Download Process
For each SRA accession:
1. **Prefetch**: Downloads SRA file to cache (`data/sra/`)
2. **Convert**: Uses `fastq-dump` to create `.fastq.gz` files in `data/raw/DATASET_ID/`
3. **Verify**: Checks FASTQ files were created successfully

### Step 3: Output
- Creates paired-end FASTQ files: `SRR1663685_1.fastq.gz`, `SRR1663685_2.fastq.gz`
- Files are stored in the correct raw data directories
- SRA cache files remain in `data/sra/` (can be deleted later to save space)
- Generates metadata JSON file
- Logs all activity to `sra_download.log`

## File Sizes

### Test Mode (`--test`)
- Downloads ~100 reads per sample
- File sizes: ~0.1-1 MB each
- Total: ~1-5 MB for testing

### Full Download
- Downloads complete datasets
- File sizes: ~500 MB - 2 GB per sample
- Total: ~15-30 GB for all datasets

## Expected Output

### Successful Test Run
```
data/
├── sra/                           # SRA cache files (temporary)
│   └── SRR1663685.sra            # (~500 MB, can delete after conversion)
└── raw/
    └── PRJNA268379/               # FASTQ files (keep these!)
        ├── SRR1663685_1.fastq.gz  (~0.5 MB in test mode)
        ├── SRR1663685_2.fastq.gz  (~0.5 MB in test mode)
        ├── SRR1663687_1.fastq.gz  (~0.5 MB in test mode)
        └── SRR1663687_2.fastq.gz  (~0.5 MB in test mode)
```

### Full Dataset
```
data/
├── sra/                           # SRA cache (can delete to save space)
│   ├── SRR1663685.sra
│   ├── SRR1663687.sra
│   └── ... (all SRA files)
└── raw/
    ├── PRJNA268379/               # Adult females FASTQ files
    │   ├── SRR1663685_1.fastq.gz  (~1.2 GB)
    │   ├── SRR1663685_2.fastq.gz  (~1.2 GB)
    │   ├── ... (30 more files)
    │   └── SRR1664192_2.fastq.gz  (~1.2 GB)
    ├── PRJNA158021/                 # Embryos FASTQ files
    │   └── ... (8 files)
    └── PRJNA187045/                 # Pharate larvae FASTQ files
        └── ... (need to get all 17 accessions)
```

## Troubleshooting

### Common Issues

1. **SRA toolkit not found**
   ```bash
   # Install in conda environment
   micromamba install -c bioconda sra-tools
   ```

2. **SRA cache configuration issues**
   ```bash
   # The script configures this automatically, but if issues persist:
   vdb-config --set /repository/user/main/public/root=data/sra
   ```

3. **Files in wrong location**
   - SRA cache should be in `data/sra/`
   - FASTQ files should be in `data/raw/DATASET_ID/`
   - Check the log messages to see where files are going

3. **Network timeouts**
   - The script has built-in timeouts and retries
   - Check internet connection
   - NCBI servers may be busy - try again later

4. **Disk space**
   - Check available space: `df -h`
   - Full datasets require ~30 GB total

### Logs

Check `sra_download.log` for detailed information:
```bash
tail -f sra_download.log
```

## Resume Downloads

The script automatically skips files that already exist and have non-zero size. To resume interrupted downloads, simply run the same command again.

## For HPC Use

This script is designed for laptop testing. For HPC deployment:
1. Convert Docker container to Singularity
2. Create SLURM job script
3. Use HPC storage and faster network

## Sample Metadata

After successful download, the script creates `data/sample_metadata.json` with information about all downloaded samples for downstream analysis.
