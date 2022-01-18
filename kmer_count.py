import sys

def gspl(seq, n):
    return [''.join(item) for item in zip(*[seq[n:] for n in range(n)])]


res = []
for line in sys.stdin.readlines():
    l = line.split('\t')
    uid = l[0]
    seqs = l[1:]
    counts = {}
    for seq in seqs:
        for kmer in gspl(seq, 3): # todo: replace second argument with length variable
            if kmer not in counts.keys():
                counts[kmer] = 1
            else:
                counts[kmer] += 1
    res.append( (uid, counts) )

with open("kmers.txt", 'w') as f: # todo: double-check filepath after pasting
    for it in res:
        f.write("$ " + it[0] + '\n')
        for k, v in it[1].items():
            f.write(f"{k} {v}\n")