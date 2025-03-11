# calculate_alignment_dnadiff
calculate alignment score using nucmer dnadiff for haplotype selection


## If you want more control

### Step 1
use `seqretsplit` so there is one fasta file per contig within the `contigs` directory

### Step 2
run batch scripts for all pairwise alignment of contigs: `./run_all_pairs.sh`

### Step 3
parse the results: `./parse.py`


## If you are lazy (recommended)
run the script `all_script.sh`

This script will do all of the steps (1-3) automatically

```shell
./all_script.sh -i assembly.fa
```

## For 2 assembly files
This can be useful to map to a reference genome
```shell
./all_script_diff.sh -i1 reference.fa -i2 assembly.fa
```


## Output
- `contigs*`: contains the split contigs
- `dnadiff_results`: contains dnadiff results
- `logs`: contains sbatch logs
- `final_sorted_report.txt`: contains final report 


