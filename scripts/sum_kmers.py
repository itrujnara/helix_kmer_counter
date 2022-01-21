"""
This script sums k-mer occurrences from multiple sequences.
Usage: python3 sum_kmers.py [input filepath] [output filepath]
Input format:
[sequence name]
[k-mer 1 content] [k-mer 1 count]
[...other k-mers]
[...other sequences]
Output format:
Aggregated data from [number] sequences:
[k-mer 1 content] [k-mer 1 count]
[...other k-mers]
"""

from collections import defaultdict as dd
import sys

def sum_kmers(infile, outfile):
    with open(infile, 'r') as infile:
        totals = dd(int)
        seqs = 0
        for line in infile:
            if line[0] == "$":
                seqs += 1
            else:
                k, v = line.split()
                totals[k] += int(v)
    with open(outfile, 'w') as outfile:
        outfile.write(f"$ Aggregated k-mers from {seqs} sequences\n")
        for k, v in sorted(totals.items(), key = lambda i: i[1], reverse = True):
            outfile.write(f"{k} {v}\n")

if __name__ == "__main__":
    try:
        infile, outfile = sys.argv[1:3]
        sum_kmers(infile, outfile)
    except ValueError:
        raise SystemExit("Check arguments. Usage: python3 sum_kmers.py [input filepath] [output filepath]")