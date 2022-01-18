#!/usr/bin/env python3
from phobius_field_retriever import *

if __name__ == "__main__":
    with open("prediction.txt", 'r') as infile:
        for line in infile:
            pred = phobius_short_pred_field_selector(line, "n", False)
            print(str(pred[0]) + '	' + '	'.join([f"{t[0]} {t[1]}" for t in pred[1]]))
