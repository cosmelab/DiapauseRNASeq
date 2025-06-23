# Docker Image Save and Transfer Guide

This guide explains how to save your Docker container as an image and prepare it for transfer to HPC clusters or other systems.

## Prerequisites

- Running Docker container with your configured environment
- Sufficient disk space (final compressed image will be 3-5 GB)
- Docker installed and running

## Step-by-Step Process

### Step 1: Commit Your Running Container

First, save your current container state as a Docker image:

```bash
# Replace 'ed554c4c334f' with your actual container ID
docker commit ed554c4c334f rnaseq-diapause:latest
```

**Important:** You can run this command from **any directory** on your host system. The `docker commit` command works with container IDs, not your current working directory.

**What this does:**
- Creates a new Docker image from your running container
- Preserves all installed tools, configurations, and files
- Tags the image as `rnaseq-diapause:latest`
- Captures the **entire container filesystem** regardless of where you run the command

### Step 2: Save the Image to a TAR File

Export the Docker image to a portable file format:

```bash
# Navigate to where you want the export file saved (optional)
cd ~/Downloads/  # or your preferred location

# Save the image to a tar file
docker save -o rnaseq-diapause.tar rnaseq-diapause:latest

# Check the file size
ls -lh rnaseq-diapause.tar
```

**Directory consideration:** The `docker save` command creates the file in your **current working directory**, so navigate to where you want the file saved before running the command.

**Expected output:**
- Creates `rnaseq-diapause.tar` (typically 8-12 GB uncompressed)
- File contains all image layers and metadata

### Step 3: Compress for Transfer

Compress the image to reduce file size and transfer time:

```bash
# Compress the image (saves significant space and transfer time)
gzip rnaseq-diapause.tar

# Check final compressed size
ls -lh rnaseq-diapause.tar.gz
```

**Final result:**
- Creates `rnaseq-diapause.tar.gz` (typically 3-5 GB)
- Ready for upload to HPC clusters or file transfer

## What's Included in the Saved Image

Your saved image contains:
- ✅ All installed bioinformatics tools and dependencies
- ✅ Your project files and analysis scripts  
- ✅ Correct directory structure and permissions
- ✅ Environment configurations and PATH settings
- ✅ Any custom configurations or modifications

## Next Steps

### Option 1: Keep Container Running
If you want to continue working while preparing for HPC transfer:
```bash
# Container remains active for continued development
docker ps  # Verify container is still running
```

### Option 2: Stop Container
If you're finished with local testing:
```bash
# Stop the container (replace with your container ID)
docker stop ed554c4c334f

# Optional: Remove the stopped container
docker rm ed554c4c334f
```

## HPC Cluster Deployment

### For Singularity-based HPC Systems

Convert the Docker image to Singularity format:

```bash
# On HPC cluster with Singularity installed
singularity build rnaseq-diapause.sif docker-archive://rnaseq-diapause.tar.gz
```

### Loading the Image on Another Docker System

```bash
# On target system, load the image
docker load -i rnaseq-diapause.tar.gz

# Verify the image was loaded
docker images | grep rnaseq-diapause

# Run the container
docker run -it rnaseq-diapause:latest /bin/bash
```

## Quick Workflow Example

Here's the complete process showing directory considerations:

```bash
# Step 1: Commit from anywhere on your host system
docker commit ed554c4c334f rnaseq-diapause:latest

# Step 2: Navigate to where you want the export file
cd ~/Downloads/  # or wherever you prefer

# Step 3: Save and compress the image
docker save -o rnaseq-diapause.tar rnaseq-diapause:latest
gzip rnaseq-diapause.tar

# Step 4: Verify final file
ls -lh rnaseq-diapause.tar.gz
```

## File Management Tips

- **Storage space:** Ensure you have at least 15-20 GB free space during the save process
- **Transfer methods:** Use `scp`, `rsync`, or your HPC's preferred file transfer method
- **Cleanup:** Remove the uncompressed `.tar` file after compression to save space
- **Backup:** Consider keeping a local copy of the compressed image as backup

## Troubleshooting

### Large Image Size
If your image is larger than expected:
```bash
# Check what's taking up space in your image
docker history rnaseq-diapause:latest --no-trunc
```

### Transfer Interruption
For large file transfers that might be interrupted:
```bash
# Use rsync with resume capability
rsync -avz --progress --partial rnaseq-diapause.tar.gz user@hpc-cluster:/path/to/destination/
```

### Permission Issues
Ensure proper file permissions before transfer:
```bash
chmod 644 rnaseq-diapause.tar.gz
```

## Summary

This process creates a portable, self-contained version of your bioinformatics environment that can be deployed on HPC clusters or shared with collaborators. The compressed image preserves your entire working environment while being optimized for transfer and storage.