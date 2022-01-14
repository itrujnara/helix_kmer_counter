from phobius_field_retriever import *

if __name__ == "__main__":
    with open(sys.argv[1], 'r') as infile:
        with open("pred_seq.txt", 'w') as outfile:
            for line in infile:
                pred = phobius_short_pred_field_selector(line, "n", False)
                outfile.write(str(pred[0]) + '\t' + '\t'.join([f"{t[0]} {t[1]}" for t in pred[1]]) + '\n')