#!/usr/bin/env python3
import os
import re

results_dir = "dnadiff_results"
output_file = "final_sorted_report.txt"

records = []  # Each record: (contig1, contig2, avg_identity, aligned_bases, aligned_percentage)

# Iterate over all .report files in the results directory
for filename in os.listdir(results_dir):
    if not filename.endswith(".report"):
        continue
    filepath = os.path.join(results_dir, filename)
    
    # Updated regex: use a greedy match for contig1 and then capture the rest as contig2.
    mname = re.match(r"(.+)_(.+)\.report$", filename)
    if not mname:
        print(f"Skipping file with unexpected name format: {filename}")
        continue
    contig1, contig2 = mname.group(1), mname.group(2)
    
    avg_identity = None
    aligned_bases = None
    aligned_percentage = None
    
    with open(filepath, "r") as rep:
        for line in rep:
            # Capture first occurrence of "AvgIdentity"
            if avg_identity is None:
                m = re.search(r"AvgIdentity\s+([\d\.]+)", line)
                if m:
                    avg_identity = m.group(1)
            # Look for the line starting with "AlignedBases"
            if aligned_bases is None and line.lstrip().startswith("AlignedBases"):
                # Expected format: "AlignedBases        11262802(96.03%)     11210195(90.96%)"
                m2 = re.search(r"AlignedBases\s+(\d+)\(([\d\.]+)%\)", line)
                if m2:
                    aligned_bases = m2.group(1)
                    aligned_percentage = m2.group(2)
            # Stop if both are captured
            if avg_identity is not None and aligned_bases is not None:
                break

    records.append((contig1, contig2, avg_identity, aligned_bases, aligned_percentage))

# Helper to parse the percentage as float (or return 0 if not found)
def parse_perc(perc):
    try:
        return float(perc)
    except (TypeError, ValueError):
        return 0.0

# Multi-key sort: primary key: contig1 alphabetically; secondary key: aligned_percentage (descending)
sorted_records = sorted(records, key=lambda x: (x[0], -parse_perc(x[4])))

# Write out the final sorted report with all desired columns
with open(output_file, "w") as out_f:
    out_f.write("Contig1\tContig2\tAlignedBases(Ref)\tAlignedPercentage(Ref)\tAvgIdentity\n")
    for rec in sorted_records:
        c1, c2, avg_id, ab, ab_perc = rec
        if ab is None:
            ab = "NA"
            ab_perc = "NA"
        if avg_id is None:
            avg_id = "NA"
        out_f.write(f"{c1}\t{c2}\t{ab}\t{ab_perc}\t{avg_id}\n")

print(f"Parsing complete. Final sorted report written to {output_file}")

