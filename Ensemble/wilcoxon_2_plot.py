import pandas as pd

trad_metric = {"AUROC": "AUC", "AUPRC": "PRC"}
hier_methods = {"GPAV": "GPAV",
                "HTD": "HTD",
                "ISO-TPRthreshold": "ISO-TPR-AT",
                "ISO-TPRthreshold.free": "ISO-TPR-TF",
                "TPR-DAGthreshold": "TPR-DAG-AT",
                "TPR-DAGthreshold.free": "TPR-DAG-TF",
                "TPR-W": "TPR-W"}

ontos = ["BP", "MF", "CC"]
fs_ = ["FS", "PCA"]
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
            print(curr_file.keys())
            for algo in algos:
                for fs in fs_:
                    for metric in ["AUROC", "AUPRC"]:
                        met = trad_metric[metric]
                        column_name = algo + "_" + met + ".hier"+"_"+fs
                        #print(column_name)
                        dict_metric[metric][hier_methods[hier_method]][onto+algo+fs] = curr_file[column_name].mean()
                        #print(curr_file[column_name])
    print(dict_metric)

