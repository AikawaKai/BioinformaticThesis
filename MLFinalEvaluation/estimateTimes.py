import sys, os, csv
import pandas as pd
from numpy import mean

dict_num_ann = {"BP":1335, "MF":186, "CC":221}

BP_classes = ["GO:0015031", "GO:0031325", "GO:0045176", "GO:1901565", "GO:0009792",
              "GO:1901046", "GO:1903507", "GO:0048814", "GO:0048489", "GO:0006508"]

MF_classes = ["GO:0005261", "GO:0008237", "GO:0016818", "GO:0060089", "GO:0004857",
              "GO:0046872", "GO:0097159", "GO:0019887", "GO:0017048", "GO:0001664"]

CC_classes = ["GO:0005929", "GO:0030424", "GO:0043226", "GO:0098687", "GO:0005829",
              "GO:0098562", "GO:0098802", "GO:0044422", "GO:0043234", "GO:0000932"]


if __name__ == '__main__':
    dir_ = sys.argv[1]
    files = [file_ for file_ in os.listdir(dir_) if file_.endswith(".csv")]
    files = [(dir_+"/"+file_, file_) for file_ in files]
    rows = []
    for file_, name in files:
        print(file_)
        name = name.split(".csv")[0]
        name_splitted = name.split("_")
        if len(name_splitted)==3:
            FS, onto, algo = name_splitted
        else:
            FS, onto, algo1, algo2 = name_splitted
            algo = algo1+"_"+algo2
        curr_dataframe = pd.read_csv(file_)
        num_rows, num_col = curr_dataframe.shape
        indexes = [i for i in range(10, num_rows, 11)]
        curr_dataframe = curr_dataframe.iloc[indexes,:]
        print(onto)
        if onto == "MF":
            indexes = MF_classes
        elif onto == "CC":
            indexes = CC_classes
        else:
            indexes = BP_classes
        curr_dataframe = curr_dataframe.loc[curr_dataframe['class_names'].isin(indexes)]
        times = list(curr_dataframe['times'])
        row = [algo, onto, round(mean(times)/3600,2), round((mean(times)*dict_num_ann[onto])/3600,2)]
        rows.append(row)
        print(curr_dataframe.shape)
    header = ["ALGO", "ONTO", "MEAN_CLASS_TIME", "TOT_TIME"]
    with open("test.csv", "w") as file_w:
        writer = csv.writer(file_w, delimiter=",")
        writer.writerow(header)
        writer.writerows(rows)
