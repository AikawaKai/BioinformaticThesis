import pandas as pd
import matplotlib.pyplot as plt
import os


algo_done = ["TPR-DAGthreshold.free", "ISO-TPRthreshold.free", "GPAV", "HTD"]


def split_name(file_name):
    res = file_name.split("_")
    return res


def put_data_in_dict(curr_csv, onto, hier_method, splitted_name, dict_onto, metrics):
    #print(splitted_name)
    for key in curr_csv.keys():
        res = split_name(key)
        if len(res)==4:
            algo = res[0]+"_"+res[1]
            metric = res[2]
            fs = res[3]
        else:
            algo = res[0]
            metric = res[1]
            fs = res[2]
        metric = hier_method+"_"+metric
        if algo not in dict_onto[onto][fs]:
            dict_onto[onto][fs][algo] = dict()
            dict_onto[onto][fs][algo][metric] = list(curr_csv[key])
        elif metric not in dict_onto[onto][fs][algo]:
            dict_onto[onto][fs][algo][metric] = list(curr_csv[key])
        if metric not in metrics:
            metrics[metric] = 0
        else:
            metrics[metric] += 1


def fill_data_dict(curr_path, hier_algo, dict_onto, metrics):
    files = [(curr_path+file_, file_) for file_ in os.listdir(curr_path)
             if file_.endswith(".csv") and file_ != hier_algo+".csv"]
    print(files)
    for file_, file_name in files:
        file_name = file_name.split(".csv")[0]
        print(file_name)
        curr_csv = pd.read_csv(file_, sep="\t")
        splitted_name = split_name(file_name)
        onto = splitted_name[0]
        hier_method = splitted_name[1]
        put_data_in_dict(curr_csv, onto, hier_method, splitted_name[2:], dict_onto, metrics)


def box_plot_by_key(algo_dict, dict_metrics, onto, fs, key):
    fig = plt.figure(figsize=(16, 30))
    num_row = len(algo_dict.keys())
    i = 0
    for algo in algo_dict.keys():
        i += 1
        algo_vals_dict = algo_dict[algo]
        ax = fig.add_subplot(num_row, 1, i)
        names = [n for n in dict_metrics.keys() if key in n]
        names_1 = []
        count = 0
        for name in names:
            if "flat" in name:
                count+=1
                if count==1:
                    names_1.append(name)
            else:
                names_1.append(name)
        metric_values = [algo_vals_dict[metric] for metric in names_1]
        ax.boxplot(metric_values, patch_artist=True)
        ax.set_xticklabels(names_1)
        ax.set_title(algo)
    fig.savefig(onto + "_" + fs + "_" + key + ".png")


def box_plot(algo_dict, dict_metrics, onto, fs):
    box_plot_by_key(algo_dict, dict_metrics, onto, fs, "AUC")
    box_plot_by_key(algo_dict, dict_metrics, onto, fs, "PRC")
    box_plot_by_key(algo_dict, dict_metrics, onto, fs, "FMM")





def get_box_plot_from_dict_data(dict_onto, dict_metrics):
    for onto in ["BP", "MF", "CC"]:
        for fs in ["FS", "PCA"]:
            box_plot(dict_onto[onto][fs], dict_metrics, onto, fs)


if __name__ == '__main__':
    path_ = "/home/kai/Documenti/UNIMI/BioinformaticThesis/Ensemble/hierPerf"
    dict_onto = {key: {"FS": dict(), "PCA": dict()} for key in ["BP", "MF", "CC"]}
    dict_metrics = dict()
    dict_algos = dict()
    for hier_algo in algo_done:
        curr_path = path_+"/"+hier_algo+"/"
        metrics = fill_data_dict(curr_path, hier_algo, dict_onto, dict_metrics)
    print(dict_onto["BP"]["FS"]["LogitBoost"])
    print(dict_metrics)
    print(dict_algos)
    get_box_plot_from_dict_data(dict_onto, dict_metrics)

