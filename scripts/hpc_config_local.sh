#!/bin/bash

# Configuration file for environment-specific settings
# This is your local configuration with actual HPC paths

# Base directory for the project
export BASE_DIR="/bigdata/cosmelab/lcosme/docker"

# Container path
export CONTAINER_PATH="${BASE_DIR}/diapause-rnaseq.sif"

# Bind paths for Singularity
# Format: "host_path:container_path"
export BIND_PATHS="${BASE_DIR}:/proj"

# Nextflow configuration
export NXF_CONFIG="${BASE_DIR}/nf-core/configs/hpc_batch.conf"

# Print configuration
echo "Configuration:"
echo "BASE_DIR: $BASE_DIR"
echo "CONTAINER_PATH: $CONTAINER_PATH"
echo "BIND_PATHS: $BIND_PATHS"
echo "NXF_CONFIG: $NXF_CONFIG" 