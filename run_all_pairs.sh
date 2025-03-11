#!/bin/bash

# Directory containing individual contig FASTA files.
CONTIG_DIR="contigs"

# Create output directories if they don't exist.
mkdir -p dnadiff_results

# Loop over all unique pairs of contig files.
for f1 in "$CONTIG_DIR"/*; do
    for f2 in "$CONTIG_DIR"/*; do
        # Avoid self-comparison and duplicate pairs (compare only if f1 comes before f2)
        if [[ "$f1" < "$f2" ]]; then
            echo "Submitting job for: $f1 and $f2"
            sbatch dnadiff_job.sbatch "$f1" "$f2"
        fi
    done
done
