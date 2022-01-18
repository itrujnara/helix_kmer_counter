import sys
import itertools

def extract_seqs(seq, ints): # separated to limit indentation
    seqs = []
    current = ""
    bpts = list(itertools.chain.from_iterable(ints))
    write = False
    for i, c in enumerate(seq): # todo: what indexing in Phobius
        if (i + 1) in bpts:
            write = not write # start/stop reading sequence
            if not write: # save and reset at the end of sequence
                seqs.append(current)
                current = ""
        if write:
            current += c
    return seqs

def extract_seqs(predfile, fastafile, outfile):
    with open(fastafile, 'r') as inseqs: # todo: change file name to "inseqs.fa" after pasting into Nextflow
        with open(predfile, 'r') as preds:
            with open(outfile, 'w') as out:
                for pred in preds:
                    l = pred.split('\t')
                    uid = l[0] # first item is the sequence ID
                    ints = [[int(a), int(b)] for [a, b] in [p.split() for p in l[1:]]] # other items are intervals
                    found = False
                    for sl in inseqs:
                        if found:
                            out.write(uid + '\t' + '\t'.join(extract_seqs(sl, ints)) + '\n')
                            break
                        elif sl.split()[0][1:] == uid:
                            found = True