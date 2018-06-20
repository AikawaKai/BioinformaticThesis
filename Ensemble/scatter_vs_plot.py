import pandas as pd
from itertools import combinations
import matplotlib.pyplot as plt

trad_metric = {"AUROC": "AUC", "AUPRC": "PRC"}
hier_methods = {"GPAV": "GPAV",
                "HTD": "HTD",
                "ISO-TPRthreshold": "ISO-TPR-AT",
                "ISO-TPRthreshold.free": "ISO-TPR-TF",
                "TPR-DAGthreshold": "TPR-DAG-AT",
                "TPR-DAGthreshold.free": "TPR-DAG-TF",
                "TPR-W": "TPR-W"}

ontos = ["BP", "MF", "CC"]
fs_ = ["PCA", "FS"]
algos = ["adaboost", "C5.0", "glmnet", "mlp", "xgbLinear", "LogitBoost",
         "lda", "treebag", "naive_bayes", "svmLinear2", "ranger", "kknn"]

if __name__ == '__main__':
    dict_metric = {"AUROC": {value: dict() for key, value in hier_methods.items()},
                   "AUPRC": {value: dict() for key, value in hier_methods.items()}}
    path = "/home/kai/Documenti/UNIMI/BioinformaticThesis/Ensemble/hierPerf/"
    for hier_method in hier_methods.keys():
        path_hier = path+hier_method+"/"
        for onto in ontos:
            file_ = onto + "_" + hier_method + ".csv"
            curr_file = pd.read_csv(path_hier + file_, sep="\t")
            for algo in algos:
                for fs in fs_:
                    for metric in ["AUROC", "AUPRC"]:
                        met = trad_metric[metric]
                        column_name = algo + "_" + met + ".hier"+"_"+fs
                        #print(column_name)
                        dict_metric[metric][hier_methods[hier_method]][onto+algo+fs] = curr_file[column_name].mean()
                        #print(curr_file[column_name])

    basic_combos = list(combinations(hier_methods.values(), 2))
    figs = [plt.figure(figsize=(26, 26)) for i in range(4)]
    for fs in fs_:
        j = 0
        for metric in ["AUROC", "AUPRC"]:
            met = trad_metric[metric]
            fig = figs[0]
            j += 1
            fig.subplots_adjust(wspace=0.3, hspace=0.2)
            i = 0
            for comb in basic_combos:
                i += 1
                hier_method1 = comb[0]
                hier_method2 = comb[1]
                ax = fig.add_subplot(5, 5, i)
                val_x = []
                val_y = []
                for algo in algos:
                    for onto in ontos:
                        hier_method1_val = dict_metric[metric][hier_method1][onto+algo+fs]
                        hier_method2_val = dict_metric[metric][hier_method2][onto+algo+fs]
                        #print(hier_method1_val, hier_method2_val)
                        val_x.append(hier_method1_val)
                        val_y.append(hier_method2_val)
                        #print(hier_method1_val, hier_method2_val)
                if metric == "AUPRC":
                    ax.plot([0, 1], "black")
                ax.scatter(val_x, val_y)
                ax.set_ylabel(hier_method2, fontsize=20)
                ax.set_xlabel(hier_method1, fontsize=20)
        fig.suptitle("SCATTER "+ fs + " AUROC & AUPRC", fontsize=50)
        fig.savefig("scatterplot_"+fs+".png")
        fig.clear()




