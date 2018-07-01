import pandas as pd
import matplotlib.pyplot as plt
import os
from scipy.stats import wilcoxon
from itertools import combinations, product
import csv
from numpy import mean


algo_done = ["GPAV", "HTD", "TPR-DAGthreshold.free", "ISO-TPRthreshold.free", "TPR-DAGthreshold", "ISO-TPRthreshold",
             "TPR-W"]
methods_ordered = ["GPAV", "HTD", "TPR-TF", "ISO-TPR-TF", "TPR-AT",  "ISO-TPR-AT", "TPR-W"]
dict_translate_hier_method = {"TPR-DAGthreshold.free": "TPR-TF",
                              "ISO-TPRthreshold.free": "ISO-TPR-TF",
                              "TPR-DAGthreshold": "TPR-AT",
                              "GPAV": "GPAV",
                              "HTD": "HTD",
                              "flat": "flat",
                              "TPR-W": "TPR-W",
                              "ISO-TPRthreshold": "ISO-TPR-AT"}

dict_metric = {"AUC": "AUROC", "PRC": "AUPRC", "FMM": "FMM"}
blues = [(30, 144, 255), (0, 191, 255), (135, 206, 250), (173, 216, 230), (240, 248, 255)]
blues = [[val/255 for val in tupl] for tupl in blues]
print(blues)


def changeFontSize(ax, label_font, tick_font, title_font):
    ax.title.set_fontsize(title_font)
    ax.xaxis.label.set_fontsize(label_font)
    ax.yaxis.label.set_fontsize(label_font)
    ax.tick_params(axis='both', which='major', labelsize=tick_font)


def normalize_name(name):
    if "flat" in name:
        return "flat"
    else:
        return dict_translate_hier_method[name.split("_")[0]]


def split_name(file_name):
    res = file_name.split("_")
    return res


def put_data_in_dict(curr_csv, onto, hier_method, splitted_name, dict_onto, metrics):
    #print(splitted_name)
    for key in curr_csv.keys():
        res = split_name(key)
        if len(res) == 4:
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


def wilcoxon_test_by_metric_no_sparse(algo_dict, dict_metrics, key):
    i = 0
    with open("./csv/" + key + "/p_value.csv", "w") as w:
        writer = csv.writer(w, delimiter="\t")
        writer.writerow(["algo", "FS", "ONTO", "hier1", "hier2", "p-value", "hier1-hier2"])
        for onto in ["BP", "MF", "CC"]:
            algo_dict_list = [algo for algo in algo_dict[onto]["FS"]]
            for fs in ["FS", "PCA"]:
                for algo in algo_dict_list:
                    i += 1
                    algo_vals_dict = algo_dict[onto][fs][algo]
                    names = [n for n in dict_metrics.keys() if key in n]
                    names_1 = []
                    count = 0
                    for name in names:
                        if "flat" in name:
                            count += 1
                            if count == 1:
                                names_1.append(name)
                        else:
                            names_1.append(name)
                    metric_values = [algo_vals_dict[metric] for metric in names_1]
                    names_1 = [normalize_name(n) for n in names_1]
                    zip_metric_names = zip(metric_values, names_1)
                    metric_values_by_comb = combinations(zip_metric_names, 2)
                    for comb in metric_values_by_comb:
                        print(algo, onto, key, fs, "Comparison between: ", comb[0][1], ",", comb[1][1])
                        curr_wilcoxon = wilcoxon(comb[0][0], comb[1][0])
                        hier_score = sum([comb[0][0][i]-comb[1][0][i] for i in range(len(comb[0][0]))])/len(comb[0][0])
                        if curr_wilcoxon[1] < 0.01:
                            writer.writerow([algo, fs, onto, comb[0][1], comb[1][1], round(curr_wilcoxon[1], 5), hier_score])


def get_hierchical_method_names_from_dict(dict_metric, key):
    names = [n for n in dict_metrics.keys() if key in n]

    names_1 = []
    count = 0
    for name in names:
        if "flat" in name:
            count += 1
            if count == 1:
                names_1.append(name)
        else:
            names_1.append(name)
    return names_1


def fill_dataframe2(tot_df, algo_df, curr_wilcoxon, comb, algo, onto, fs):
    hierch1 = comb[0][1]
    hierch2 = comb[1][1]
    p_value = curr_wilcoxon[1]
    if p_value < 0.01 / 12:
        hier_score = mean(comb[0][0]) - mean(comb[1][0])
        if hierch1 == 'flat':
            if hier_score < 0:
                tot_df.loc[algo, hierch2] += 1
        else:
            if hier_score > 0:
                tot_df.loc[algo, hierch1] += 1


def fill_dataframe(tot_df, algo_df, curr_wilcoxon, comb, algo, onto, fs):
    hierch1 = comb[0][1]
    hierch2 = comb[1][1]
    p_value = curr_wilcoxon[1]
    if p_value < 0.01/12:
        hier_score = mean(comb[0][0]) - mean(comb[1][0])
        if hier_score > 0:
            if(hierch1 == "flat"):
                algo_df.loc[algo, fs+"_"+onto] += 1
            tot_df.loc[hierch1, hierch2][0] += 1
            tot_df.loc[hierch2, hierch1][2] += 1

        elif hier_score < 0:
            if (hierch2 == "flat"):
                algo_df.loc[algo, fs+"_"+onto] += 1
            tot_df.loc[hierch2, hierch1][0] += 1
            tot_df.loc[hierch1, hierch2][2] += 1

        else:
            if(hierch2 == "flat" or hierch1 == "flat"):
                algo_df.loc[algo, fs + "_" + onto] += 1
            tot_df.loc[hierch1, hierch2][1] += 1
            tot_df.loc[hierch2, hierch1][1] += 1
    else:
        if (hierch2 == "flat" or hierch1 == "flat"):
            algo_df.loc[algo, fs + "_" + onto] += 1
        tot_df.loc[hierch1, hierch2][1] += 1
        tot_df.loc[hierch2, hierch1][1] += 1



def wilcoxon_test_by_metric(algo_dict, dict_metrics, onto, key, algo_df, tot_df_fs, tot_df_pca):
    num_row = len(algo_dict["FS"].keys())*2
    i = 0
    algo_dict_list = [algo for algo in algo_dict["FS"]]
    names = get_hierchical_method_names_from_dict(dict_metrics, key)
    # print(names)
    names_1 = [normalize_name(n) for n in names]
    for fs in ["FS", "PCA"]:
        print("Current config: ", onto, key, fs)
        tot_df = pd.DataFrame(columns=names_1, index=names_1)
        for nam1 in names_1:
            for nam2 in names_1:
                tot_df.loc[nam1, nam2] = [0, 0, 0]
        for algo in algo_dict_list:
            i += 1
            algo_vals_dict = algo_dict[fs][algo]
            metric_values = [algo_vals_dict[metric] for metric in names]
            curr_df = pd.DataFrame(columns=names_1, index=names_1)
            zip_metric_names = zip(metric_values, names_1)
            metric_values_by_comb = combinations(zip_metric_names, 2)
            for comb in metric_values_by_comb:
                #print("Comparison between: ", comb[0][1], ",", comb[1][1])
                curr_wilcoxon = wilcoxon(comb[0][0], comb[1][0])
                #print("p_value", curr_wilcoxon[1])
                curr_df.loc[comb[0][1], comb[1][1]] = curr_wilcoxon[1]
                #print(curr_df.loc[comb[0][1], comb[1][1]])
                curr_df.loc[comb[1][1], comb[0][1]] = curr_wilcoxon[1]
                if comb[0][1] == 'flat' or comb[1][1] == 'flat':
                    if fs == "FS":
                        fill_dataframe2(tot_df_fs, algo_df, curr_wilcoxon, comb, algo, onto, fs)
                    else:
                        fill_dataframe2(tot_df_pca, algo_df, curr_wilcoxon, comb, algo, onto, fs)
                fill_dataframe(tot_df, algo_df, curr_wilcoxon, comb, algo, onto, fs)
            curr_df.to_csv(path_or_buf="./csv/"+key+"/"+onto+"/"+"x_algo/"+algo+"_"+fs+".csv")
        tot_df.to_csv(path_or_buf="./csv/" + key + "/" + onto + "/" + fs + ".csv", sep="\t")
        # print(tot_df)
    #print(tot_df)

def write_scores(algo_dict_list, scores_df, dict_metrics, met):
    pass



def get_wilcoxon_test_from_dict_data(algo_dict, dict_metrics):
    comb = product(["FS", "PCA"], ["BP", "MF", "CC"])
    names = [c[0]+"_"+c[1] for c in comb]
    algo_dict_list = [algo for algo in algo_dict["BP"]["FS"]]

    for met in ["AUC", "PRC"]:
        algo_df = getalgo_df(algo_dict_list, names)
        tot_df_fs = getTot_Df_new(algo_dict_list)
        tot_df_pca = getTot_Df_new(algo_dict_list)
        scores_df = pd.DataFrame(columns=methods_ordered, index=["BP", "MF", "CC"])
        write_scores(algo_dict_list, scores_df, dict_metrics, met)
        for onto in ["BP", "MF", "CC"]:
            wilcoxon_test_by_metric(algo_dict[onto], dict_metrics, onto, met, algo_df, tot_df_fs, tot_df_pca)
        algo_df.to_csv(path_or_buf="./csv/" + met + "_.csv", sep="\t")
        tot_df_fs.to_csv(path_or_buf="./csv/FS_" + met + "_1.csv", sep="\t")
        tot_df_pca.to_csv(path_or_buf="./csv/PCA_" + met + "_1.csv", sep="\t")


def getalgo_df(algo_dict_list, names):
    algo_df = pd.DataFrame(columns=names, index=algo_dict_list)
    for nam1 in names:
        for al in algo_dict_list:
            algo_df.loc[al, nam1] = 0
    return algo_df


def getTot_Df_new(algo_dict_list):
    names1 = methods_ordered
    tot_df = pd.DataFrame(index=algo_dict_list, columns=names1)
    for algo in algo_dict_list:
        for nam1 in names1:
            tot_df.loc[algo, nam1] = 0
    return tot_df

if __name__ == '__main__':
    path_ = "/home/kai/Documenti/UNIMI/BioinformaticThesis/Ensemble/hierPerf"
    dict_onto = {key: {"FS": dict(), "PCA": dict()} for key in ["BP", "MF", "CC"]}
    dict_metrics = dict()
    dict_algos = dict()
    for hier_algo in algo_done:
        curr_path = path_+"/"+hier_algo+"/"
        fill_data_dict(curr_path, hier_algo, dict_onto, dict_metrics)
    get_wilcoxon_test_from_dict_data(dict_onto, dict_metrics)

