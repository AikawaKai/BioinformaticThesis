import csv
import pandas as pd
import os
import matplotlib.pyplot as plt
from matplotlib.patches import Patch
from scipy.stats import ks_2samp

# set di colori (si possono modificare a piacimento. Devono essere esattamente 12)
from scipy.linalg import hadamard

colors = ['red', 'blue', 'green', 'yellow', 'grey',
          'brown', 'pink', 'lightblue', 'lightgreen', 'magenta',
          'gold', 'orangered']

dict_algo = {"adaboost" : "ada", "C5.0" : "C5", "svmLinear2" : "svmL", "lda": "lda", "ranger": "ran", "mlp": "mlp",
             "glmnet" : "glm", "xgbLinear" : "xgb", "kknn": "knn", "LogitBoost": "LB", "naive_bayes": "nb",
             "treebag": "tree"}

# controlla se la stringa è castabile float
def cast_float(val):
    try:
        float(val)
        return True
    except Exception as e:
        return False


def changeFontSize(ax, label_font, tick_font, title_font):
    ax.title.set_fontsize(title_font)
    ax.xaxis.label.set_fontsize(label_font)
    ax.yaxis.label.set_fontsize(label_font)
    ax.tick_params(axis='both', which='major', labelsize=tick_font)



# parsing del nome del file
# formato {tipo_feature_selection}_{ontologia}_{algoritmo}
# ES:  FS_MF_LogitBoost   oppure  PCA_MF_LogitBoost
def split_file_name(name):
    name = name.split(".csv")[0]
    names = name.split("_")
    if len(names) == 4:
        type_, onto, algo1, algo2 = names
        return type_, onto, algo1 + "_" + algo2
    return names


def versusBoxPlot(vals_FS, vals_PCA, onto):
    names_1 = sorted(vals_FS.keys(), key=lambda x : x.lower())
    print(names_1)
    names_ = [dict_algo[name] for name in names_1]
    names_couple = []
    p_value_name = []
    for i in range(len(names_)):
        names_couple.append(names_[i]+"_FS")
        names_couple.append(names_[i]+"_PCA")
        p_value_name.append(names_1[i])

    values_couple_auroc = []
    values_couple_auprc = []
    p_value_auroc = []
    p_value_auprc = []
    for algo in names_1:
        values_couple_auroc.append(vals_FS[algo]["AUROC"])
        values_couple_auroc.append(vals_PCA[algo]["AUROC"])
        print(ks_2samp(vals_FS[algo]["AUROC"], vals_PCA[algo]["AUROC"]))
        p_value_auroc.append(round(ks_2samp(vals_FS[algo]["AUROC"], vals_PCA[algo]["AUROC"])[1], 10))

        values_couple_auprc.append(vals_FS[algo]["AUPRC"])
        values_couple_auprc.append(vals_PCA[algo]["AUPRC"])
        p_value_auprc.append(round(ks_2samp(vals_FS[algo]["AUPRC"], vals_PCA[algo]["AUPRC"])[1], 10))
    print(values_couple_auroc)


    title_ = "FS_vs_PCA_"+onto+"_"+"AUROC"

    with open(title_+".csv", "w") as csv_to_write:
        writer = csv.writer(csv_to_write, delimiter="\t")
        writer.writerow(p_value_name)
        writer.writerow(p_value_auroc)
    fig = plt.figure(figsize=(16, 5))
    ax = fig.add_subplot(111)
    bp = ax.boxplot(values_couple_auroc, patch_artist=True)
    colors_ = ["lightgreen", "lightblue"]
    i = 0
    for box in bp['boxes']:
        if i % 2 == 0:
            box.set(facecolor=colors_[0])
        else:
            box.set(facecolor=colors_[1])
        i += 1
    ax.set_title(title_)
    ax.set_ylabel("AUROC")
    ax.set_xlabel('ALGORITMI')
    legend_elements = [Patch(facecolor='lightgreen', edgecolor='black',
                             label='Feature Selection'),
                       Patch(facecolor='lightblue', edgecolor='black',
                             label='PCA')]
    ax.legend(handles=legend_elements , loc='lower left')
    ax.set_xticklabels(names_couple)
    changeFontSize(ax, 12, 8, 14)

    plt.savefig(title_ + ".png")

    title_ = "FS_vs_PCA_" + onto + "_" + "AUPRC"
    with open(title_+".csv", "w") as csv_to_write:
        writer = csv.writer(csv_to_write, delimiter="\t")
        writer.writerow(p_value_name)
        writer.writerow(p_value_auprc)
    fig = plt.figure(figsize=(16, 5))
    ax = fig.add_subplot(111)
    bp = ax.boxplot(values_couple_auprc, patch_artist=True)
    colors_ = ["lightgreen", "lightblue"]
    i = 0
    for box in bp['boxes']:
        if i % 2 == 0:
            box.set(facecolor=colors_[0])
        else:
            box.set(facecolor=colors_[1])
        i += 1
    ax.set_title(title_)
    ax.set_ylabel("AUPRC")
    ax.set_xlabel('ALGORITMI')
    legend_elements = [Patch(facecolor='lightgreen', edgecolor='black',
                             label='Feature Selection'),
                       Patch(facecolor='lightblue', edgecolor='black',
                             label='PCA')]
    ax.legend(handles=legend_elements, loc='upper left')
    ax.set_xticklabels(names_couple)
    changeFontSize(ax, 12, 8, 14)

    plt.savefig(title_ + ".png")


def get_vals_by_algo_onto(path_curr, onto):
    path_ = path_curr[0]+"/"+onto+"/"
    files_ = [[path_+file_, split_file_name(file_)] for file_ in os.listdir(path_) if file_.endswith(".csv")]
    dict_algo = {}
    for file_path, file_ in files_:
        data_ = pd.read_csv(file_path, sep="\t")
        curr_algo = file_[2]
        dict_algo[curr_algo] = dict()
        keys = [name for name in data_.keys() if name != "Unnamed: 0"]
        for key in keys:
            dict_algo[curr_algo][key] = list(data_[key])
    return dict_algo


# main
if __name__ == '__main__':
    path_FS = ["./csv_resume/FS/", "FS"]
    path_PCA = ["./csv_resume/PCA/", "PCA"]
    ontos = ["BP", "MF", "CC"]
    for onto in ontos:
        print("[INFO] CURRENT ONT0: ", onto)
        vals_FS = get_vals_by_algo_onto(path_FS, onto)
        vals_PCA = get_vals_by_algo_onto(path_PCA, onto)
        versusBoxPlot(vals_FS, vals_PCA, onto)
        print("")
    """   
    files = [(directory_ + "/" + file_, file_) for file_ in os.listdir(directory_)
             if file_.endswith(".csv")]
    list_dicts = []
    for file_, name in files:
        # type_, onto, algo = split_file_name(name)
        dict_result = get_data_from_csv(file_)
        list_dicts.append([name, dict_result])
    list_dicts = sorted(list_dicts, key=lambda x: x[0].lower())
    write_box_plots(list_dicts)
    """
