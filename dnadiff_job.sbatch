#!/bin/bash
#SBATCH --job-name=dnadiff_job
#SBATCH -p compute
#SBATCH --output=logs/dnadiff_job_%j.out
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=4

# Load modules if required (example: mummer)
# module load mummer

# Two positional arguments: contig file 1 and contig file 2
f1="$1"
f2="$2"

# Create base names for output prefix (removing extensions)
base1=$(basename "$f1" | sed 's/\..*//')
base2=$(basename "$f2" | sed 's/\..*//')
prefix="${base1}--${base2}"

# Create an output directory for dnadiff results
mkdir -p dnadiff_results

# Set environment variable to adjust nucmer's behavior for larger alignments:
# -l 150 sets the minimum exact match length to 150 bp,
# -c 500 sets the minimum cluster length to 500 bp.
export NUCMEROPT="-l 1000 -c 5000"

# Run dnadiff via Singularity using the specified container
singularity exec /flash/LuscombeU/singularity.cacheDir/mummer_3.23--pl5321h503566f_21.sif \
    dnadiff -p dnadiff_results/"$prefix" "$f1" "$f2"
