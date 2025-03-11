# calculate_alignment_dnadiff
calculate alignment score using nucmer dnadiff for haplotype selection


## Step 1
use `seqretsplit` so there is one fasta file per contig within the `contigs` directory

## Step 2
run batch scripts for all pairwise alignment of contigs: `./run_all_pairs.sh`

## Step 3
parse the results: `./parse.py`
