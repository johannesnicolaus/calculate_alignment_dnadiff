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

## final_sorted_report.txt

The final result should look like this:
```
Contig1 Contig2 AlignedBases(Ref)       AlignedPercentage(Ref)  AvgIdentity
chr1    10a20231a1b     7274533 59.03   94.67
chr1    10a10011a1b     6062674 49.19   95.12
chr1    11a10358a1b     4139598 33.59   92.09
chr1    10a16866a1b     4132567 33.53   92.25
chr1    10a31518a1b     1609785 13.06   93.93
chr1    10a65083a2b     1120115 9.09    93.37
chr1    10a7136a1b      1065420 8.65    93.24
chr1    21a30011a1b     949630  7.71    93.26
chr1_alt        10a20231a1b     6754923 57.59   94.73
chr1_alt        10a10011a1b     6068991 51.75   95.15
chr1_alt        11a10358a1b     4157105 35.44   92.11
chr1_alt        10a16866a1b     4131943 35.23   92.22
chr1_alt        10a65083a2b     1132374 9.65    93.32
```

The column `AlignedBases(Ref)` might be the one you can use to infer haplotype
