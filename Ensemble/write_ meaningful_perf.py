import pandas as pd
from scipy.stats import wilcoxon
from numpy import mean, std
from math import sqrt
import csv


methods = ["flat", "HTD", "GPAV", "TPR-DAGthreshold.free", "ISO-TPRthreshold.free", "TPR-DAGthreshold",
           "ISO-TPRthreshold", "TPR-W"]

ontos = ["BP", "MF", "CC"]

metrics = {"AUC": "AUROC", "PRC": "AUPRC"}

fs_ = ["FS", "PCA"]

algos = ['adaboost', 'C5.0', 'glmnet', 'kknn', 'lda', 'LogitBoost', 'mlp', 'naive_bayes', 'ranger', 'svmLinear2',
         'treebag', 'xgbLinear']


def get_algo_names(list_header):
    names = [list_header[i].split("_")[0] for i in range(len(list_header )//2) if i%4 == 0]
    names[7] = "naive_bayes"
    return names



def get_dict_all_performance(fs):
    all_dict = {"AUC": {onto: {algo: {method: [] for method in methods} for algo in algos} for onto in ontos},
                "PRC": {onto: {algo: {method: [] for method in methods} for algo in algos} for onto in ontos}}
    for method in methods[1:]:
        curr_path = dir_path + per_path + method + "/"
        print(curr_path)
        for onto in ontos:
            file_name = onto + "_" + method + ".csv"
            file_ = curr_path + file_name
            curr_method_file = pd.read_csv(file_, sep="\t")
            for algo in algos:
                for metric in metrics.keys():
                    for m in ["flat", "hier"]:
                        curr_col_name = algo+"_" + metric + "." + m + "_" + fs
                        curr_vals = curr_method_file[curr_col_name]
                        #print(curr_vals)
                        if m == "flat":
                            all_dict[metric][onto][algo][m] = list(curr_vals)
                        else:
                            all_dict[metric][onto][algo][method] = list(curr_vals)
    return all_dict


def write_perf_results(curr_fs, curr_dict_all_performance):
    for metric in metrics.keys():
        curr_csv_path = dir_path + "/csv/" + metric + "/results/" + curr_fs + ".csv"
        with open(curr_csv_path, "w") as to_write:
            writer = csv.writer(to_write, delimiter="\t")
            writer.writerow(["algo", "onto"]+methods)
            for algo in algos:
                for onto in ontos:
                    dict_x_methods = curr_dict_all_performance[metric][onto][algo]
                    res = [dict_x_methods[method] for method in methods]
                    wilcoxon_res = [0 for el in methods]
                    for i in range(1, len(methods)):
                        wilcoxon_res[i] = wilcoxon(res[0], res[i])[1]
                    #print(wilcoxon_res)
                    res = [repr([round(mean(res[i]), 4), round(std(res[i])/sqrt(len(res[i])), 4),
                            round(wilcoxon_res[i], 4)]) for i in range(len(res))]
                    print(res)
                    writer.writerow([algo]+[onto]+res)

if __name__ == '__main__':
    dir_path = "/home/kai/Documenti/UNIMI/BioinformaticThesis/Ensemble/"
    per_path = "/hierPerf/"
    dict_all_performance_fs = get_dict_all_performance("FS")
    dict_all_performance_pca = get_dict_all_performance("PCA")
    curr_fs = "FS"
    write_perf_results(curr_fs, dict_all_performance_fs)
    curr_fs = "PCA"
    write_perf_results(curr_fs, dict_all_performance_pca)