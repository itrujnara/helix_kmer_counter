#!/bin/bash -ue
python3 extract_seqs.py seq_ranges.txt sample_fasta.fa seqs.txt
# rm -f seq_ranges.txt
