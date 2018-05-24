import pandas as pd
import os
from collections import OrderedDict


def get_values_by_algo(files):
    dict_by_algo = dict()
    for file_ in files:
        metric = file_[2][0]
        readed = pd.read_csv(file_[0], sep="\t")
        col = readed.keys()
        for algo in col:
            if algo not in dict_by_algo:
                dict_by_algo[algo] = {metric: list(readed[algo])}
            else:
                dict_by_algo[algo][metric] = list(readed[algo])
    return dict_by_algo


def write_csv_onto(dict_onto, select):
    for onto, files in dict_onto.items():
        print("[INFO] Parsing current onto: ", onto)
        values = get_values_by_algo(files)
        for algo, metrics in values.items():
            dict_algo = OrderedDict()
            for metric, value in metrics.items():
                dict_algo[metric] = value
            file_name = "./csv_resume/"+select+"/"+onto+"/"+select+"_"+onto+"_"+algo+".csv"
            pd.DataFrame(dict_algo).to_csv(path_or_buf=file_name, sep="\t")



def get_dict_onto(selection):
    dict_onto = {onto:[] for onto in ["BP", "MF", "CC"]}
    for file_ in selection:
        curr_onto = file_[2][1]
        dict_onto[curr_onto].append(file_)
    return dict_onto


def get_metric_onto_selection(file_):
    metric, onto, selection = file_.split(".csv")[0].split("_")
    return metric, onto, selection


if __name__ == '__main__':
    path_ = "./csv_resume/"
    files = [(path_+file_, file_, get_metric_onto_selection(file_)) for file_ in os.listdir(path_)
             if file_.endswith(".csv")]
    files_FS = [file_ for file_ in files if file_[2][2] == "FS"]
    files_PCA = [file_ for file_ in files if file_[2][2] == "PCA"]
    print(files_FS)
    print(files_PCA)
    for selection in [files_FS, files_PCA]:
        first = selection[0]
        select = first[2][2]
        dict_onto = get_dict_onto(selection)
        write_csv_onto(dict_onto, select)