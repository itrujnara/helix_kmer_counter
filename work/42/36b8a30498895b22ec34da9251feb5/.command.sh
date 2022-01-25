#!/usr/bin/env bash
python3 kmer_count.py seqs.txt seq_kmers.txt 3
rm -rf /home/igor/Programming/CRG/helix_kmer_counter/tmp/extractSequences
