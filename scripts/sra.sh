#!/bin/sh
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=2gb
#SBATCH --time=48:00:00
#SBATCH --partition=week
#SBATCH --job-name=sra_download
#SBATCH --array=1-3
#SBATCH -o sra_download_%A_%a.o.txt
#SBATCH -e sra_download_%A_%a.ERROR.txt

CONTAINER_PATH="/ycga-gpfs/project/caccone/lvc26/docker/diapause-rnaseq.sif"
BIND_PATH="/ycga-gpfs/project/caccone/lvc26/docker:/proj"

# Define the datasets
DATASETS=("PRJNA268379" "PRJNA158021" "PRJNA187045")
DATASET=${DATASETS[$((SLURM_ARRAY_TASK_ID-1))]}

echo "Job started at: $(date)"
echo "Processing dataset: $DATASET"
echo "Array Task ID: $SLURM_ARRAY_TASK_ID"

# Download this dataset (NO --test flag = download everything)
apptainer exec --bind $BIND_PATH $CONTAINER_PATH bash -c "cd /proj && python scripts/sra_download.py --dataset $DATASET --output-dir data --max-workers 6"

echo "Dataset $DATASET completed at: $(date)"