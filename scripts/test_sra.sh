#!/bin/sh
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=2gb
#SBATCH --time=48:00:00
#SBATCH --partition=week
#SBATCH --job-name=sra_test_array
#SBATCH --array=1
#SBATCH -o sra_test_%A_%a.o.txt
#SBATCH -e sra_test_%A_%a.ERROR.txt

# Container settings
CONTAINER_PATH="/ycga-gpfs/project/caccone/lvc26/docker/diapause-rnaseq.sif"
BIND_PATH="/ycga-gpfs/project/caccone/lvc26/docker:/proj"

# Test with just one dataset
DATASETS=("PRJNA268379")
DATASET=${DATASETS[$((SLURM_ARRAY_TASK_ID-1))]}

echo "Testing array job for dataset: $DATASET"
echo "Started at: $(date)"

# Run in test mode (only first 2 files)
apptainer exec --bind $BIND_PATH $CONTAINER_PATH bash -c "cd /proj && python scripts/sra_download.py --dataset $DATASET --test --output-dir data/sra --max-workers 2"

echo "Test completed at: $(date)"