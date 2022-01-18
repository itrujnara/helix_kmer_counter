import sys
from collections import defaultdict as dd

def gspl(seq, n):
    return [''.join(item) for item in zip(*[seq[n:] for n in range(n)])]

def count_kmers(infile, outfile, k_len):
    res = []
    for line in sys.stdin.readlines():
        l = line.split('\t')
        uid = l[0]
        seqs = l[1:]
        counts = dd(int)
        for seq in seqs:
            for kmer in gspl(seq, 3): # todo: replace second argument with length variable
                counts[kmer] += 1
        res.append( (uid, counts) )

    with open("kmers.txt", 'w') as f: # todo: double-check filepath after pasting
        for it in res:
            f.write("$ " + it[0] + '\n')
            for k, v in sorted(it[1].items(), key = lambda it: it[1]):
                f.write(f"{k} {v}\n")

if __name__ == "__main__":
    infile, outfile, k_len = sys.argv[1:4]
    count_kmers(infile, outfile, k_len)