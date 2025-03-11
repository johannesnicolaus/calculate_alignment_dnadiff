#!/bin/bash
# run_all.sh: Run the entire pipeline from splitting the assembly into contigs,
# submitting all-to-all dnadiff comparisons via sbatch, waiting for them to finish,
# and finally parsing the results to generate the final report.
#
# Usage: ./run_all.sh -i assembly.fa

usage() {
    echo "Usage: $0 -i assembly.fa"
    exit 1
}

# Parse input arguments
while getopts "i:" opt; do
    case $opt in
      i) assembly="$OPTARG" ;;
      *) usage ;;
    esac
done

if [ -z "$assembly" ]; then
    usage
fi

if [ ! -f "$assembly" ]; then
    echo "Error: $assembly not found!"
    exit 1
fi

echo "Starting pipeline for assembly: $assembly"

##############################
# STEP 1: Split assembly into contigs using EMBOSS seqretsplit
##############################
echo "Loading EMBOSS module..."
ml emboss || { echo "EMBOSS module not available."; exit 1; }

contigs_dir="contigs"
rm -rf "$contigs_dir"
mkdir -p "$contigs_dir"

echo "Changing directory into '$contigs_dir' to run seqretsplit..."
# Change directory into contigs_dir so that seqretsplit writes output files there.
pushd "$contigs_dir" > /dev/null

# Run seqretsplit with the input assembly (referenced from parent directory)
echo "Running seqretsplit..."
seqretsplit -sequence "../$assembly" -outseq .
if [ $? -ne 0 ]; then
    echo "seqretsplit failed!"
    popd > /dev/null
    exit 1
fi
popd > /dev/null

# Verify that contigs_dir is not empty
if [ -z "$(ls -A "$contigs_dir")" ]; then
    echo "Error: No contig files found in '$contigs_dir'."
    exit 1
fi

echo "Contigs generated in directory: $contigs_dir."

##############################
# STEP 2: Submit all-to-all dnadiff comparisons as sbatch jobs
##############################
results_dir="dnadiff_results"
rm -rf "$results_dir"
mkdir -p "$results_dir"

echo "Submitting dnadiff jobs for all unique contig pairs..."
for f1 in "$contigs_dir"/*; do
    for f2 in "$contigs_dir"/*; do
        # Avoid self-comparison and duplicate pairs (submit only if f1 comes before f2)
        if [[ "$f1" < "$f2" ]]; then
            echo "Submitting job for: $f1 and $f2"
            sbatch dnadiff_job.sbatch "$f1" "$f2"
        fi
    done
done

echo "All jobs submitted. Waiting for dnadiff jobs to complete..."
# Wait until no jobs with name 'dnadiff_job' remain in the queue.
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

