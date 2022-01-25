#!/bin/bash -ue
python3 extract_seqs.py seq_ranges.txt sample_fasta.fa seqs.txt
rm -rf /home/igor/Programming/CRG/helix_kmer_counter/tmp/findSequences
