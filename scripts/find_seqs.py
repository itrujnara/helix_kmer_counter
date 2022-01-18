from phobius_field_retriever import phobius_short_pred_field_selector
import sys

def find_sequences(infile, outfile, feature):
    with open(infile, 'r') as inf:
        with open(outfile, 'w') as of:
            for line in inf:
                pred = phobius_short_pred_field_selector(line, feature, False)
                of.write(str(pred[0]) + '\t' + '\t'.join([f"{t[0]} {t[1]}" for t in pred[1]]) + '\n')

if __name__ == "__main__":
    infile, outfile, feature = sys.argv[1:4]
    find_sequences(infile, outfile, feature)