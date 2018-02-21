import pandas as pd
import sys
import numpy as np
import matplotlib.mlab as mlab
import matplotlib.pyplot as plt


if __name__ == '__main__':
    file_name = sys.argv[1]
    type_ = file_name.split(".csv")[0]
    dataframe = pd.read_csv(file_name)
    ind = dataframe.index
    classes_ = []
    vals = []
    for i in ind:
        class_ = dataframe.loc[i,:][0]
        classes_.append(class_)
        curr_row = dataframe.loc[i,:][1:]
        count = len([float(v) for v in curr_row if float(v)<0.01])
        vals.append(count)
    print(min(vals))
    print(max(vals))
    n, bins, patches = plt.hist(vals, 20, edgecolor='black', facecolor='green', alpha=0.7)
    plt.title(type_+" histogram\n p.value < 0.01")
    plt.xlabel("Num. selected features")
    plt.ylabel("Num. classes")
    plt.savefig(type_+".png")
