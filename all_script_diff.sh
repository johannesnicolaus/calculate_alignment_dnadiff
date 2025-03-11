#!/bin/bash
# all_script_diff.sh: Pipeline to compare two different FASTA files.
# 1. Split each assembly into contigs using EMBOSS seqretsplit.
# 2. Submit all-to-all dnadiff comparisons (each contig from assembly1 vs each contig from assembly2)
#    as separate sbatch jobs.
# 3. Wait for jobs to complete.
# 4. Parse the dnadiff reports into a final sorted report.
#
# Usage: ./all_script_diff.sh -i1 assembly1.fa -i2 assembly2.fa

usage() {
    echo "Usage: $0 -i1 assembly1.fa -i2 assembly2.fa"
    exit 1
}

# Manual parsing of command-line arguments for -i1 and -i2 options.
if [ "$#" -lt 4 ]; then
    usage
fi

while [ "$#" -gt 0 ]; do
    case "$1" in
        -i1)
            shift
            assembly1="$1"
            ;;
        -i2)
            shift
            assembly2="$1"
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
    shift
done

if [ -z "$assembly1" ] || [ -z "$assembly2" ]; then
    usage
fi

if [ ! -f "$assembly1" ]; then
    echo "Error: $assembly1 not found!"
    exit 1
fi

if [ ! -f "$assembly2" ]; then
    echo "Error: $assembly2 not found!"
    exit 1
fi

echo "Starting pipeline for assemblies:"
echo "Assembly1: $assembly1"
echo "Assembly2: $assembly2"

##############################
# STEP 1: Split each assembly into contigs using EMBOSS seqretsplit
##############################

echo "Loading EMBOSS module..."
ml emboss || { echo "EMBOSS module not available."; exit 1; }

# Split Assembly1
contigs1_dir="contigs1"
rm -rf "$contigs1_dir"
mkdir -p "$contigs1_dir"
echo "Changing directory into '$contigs1_dir' for assembly1..."
pushd "$contigs1_dir" > /dev/null
echo "Running seqretsplit for assembly1..."
seqretsplit -sequence "../$assembly1" -outseq .
if [ $? -ne 0 ]; then
    echo "seqretsplit for assembly1 failed!"
    popd > /dev/null
    exit 1
fi
popd > /dev/null
if [ -z "$(ls -A "$contigs1_dir")" ]; then
    echo "Error: No contig files found in '$contigs1_dir'."
    exit 1
fi
echo "Assembly1 contigs are in '$contigs1_dir'."

# Split Assembly2
contigs2_dir="contigs2"
rm -rf "$contigs2_dir"
mkdir -p "$contigs2_dir"
echo "Changing directory into '$contigs2_dir' for assembly2..."
pushd "$contigs2_dir" > /dev/null
echo "Running seqretsplit for assembly2..."
seqretsplit -sequence "../$assembly2" -outseq .
if [ $? -ne 0 ]; then
    echo "seqretsplit for assembly2 failed!"
    popd > /dev/null
    exit 1
fi
popd > /dev/null
if [ -z "$(ls -A "$contigs2_dir")" ]; then
    echo "Error: No contig files found in '$contigs2_dir'."
    exit 1
fi
echo "Assembly2 contigs are in '$contigs2_dir'."

##############################
# STEP 2: Submit all-to-all dnadiff comparisons as sbatch jobs
##############################
results_dir="dnadiff_results"
rm -rf "$results_dir"
mkdir -p "$results_dir"

echo "Submitting dnadiff jobs for all contig pairs between assembly1 and assembly2..."
# Loop over every contig from assembly1 and every contig from assembly2.
for f1 in "$contigs1_dir"/*; do
    for f2 in "$contigs2_dir"/*; do
        echo "Submitting job for: $f1 and $f2"
        sbatch dnadiff_job.sbatch "$f1" "$f2"
    done
done

echo "All jobs submitted. Waiting for dnadiff jobs to complete..."
# Wait until no jobs with the name 'dnadiff_job' remain in the queue.
while squeue -n dnadiff_job | grep -q dnadiff; do
    echo "Jobs still running... sleeping for 60 seconds."
    sleep 60
done
echo "All dnadiff jobs completed."

##############################
# STEP 3: Parse dnadiff reports into final sorted report
##############################
echo "Parsing dnadiff reports..."
python3 parse.py
if [ $? -ne 0 ]; then
    echo "Parsing failed."
    exit 1
fi

echo "Pipeline complete. Final report is available in 'final_sorted_report.txt'."

