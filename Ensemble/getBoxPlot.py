import os
import sys
import matplotlib.pyplot as plt
import pandas as pd

colors = [ 'grey', 'pink', 'lightblue', 'lightgreen', 'magenta',
           'gold', 'orangered']

to_do = ["TPR-DAGthreshold", "TPR-W", "ISO-TPRthreshold"]

def plotData(names, vals, file_, sel):
    fig = plt.figure(figsize=(11, 11))
    ax = fig.add_subplot(111)
    bp = ax.boxplot(vals, patch_artist=True)
    ax.set_xticklabels(names)
    i = 0
    for box in bp['boxes']:
        box.set(facecolor=colors[i])
        i+=1
    plt.title(file_+"_"+sel)
    plt.savefig(file_+"_"+sel+".png")


# main
if __name__ == '__main__':
    path_FS = sys.argv[1]
    directories_ = [name for name in os.listdir(path_FS) if os.path.isdir(path_FS+"/"+name) and name not in to_do]
    print(directories_)
    names = ["flat"]
    prcVals = []
    rocVals = []
    prcValsPCA = []
    rocValsPCA = []
    prcValsFS = []
    rocValsFS = []
    for dir_ in directories_:
        curr_dir = path_FS+"/"+dir_
        curr_csv = curr_dir+"/"+dir_+".csv"
        curr_df = pd.read_csv(curr_csv, sep="\t")
        PRCflat = curr_df["PRC.flat"]
        PRCflatPCA = curr_df[curr_df["fs"] == "PCA"]["PRC.flat"]
        PRCflatFS = curr_df[curr_df["fs"] == "FS"]["PRC.flat"]

        AUCflat = curr_df["AUC.flat"]
        AUCflatPCA = curr_df[curr_df["fs"] == "PCA"]["AUC.flat"]
        AUCflatFS = curr_df[curr_df["fs"] == "FS"]["AUC.flat"]

        names.append(dir_)
        prcVals.append(curr_df["PRC.hier"])
        prcValsFS.append(curr_df[curr_df["fs"] == "FS"]["PRC.hier"])
        prcValsPCA.append(curr_df[curr_df["fs"] == "PCA"]["PRC.hier"])
        rocVals.append(curr_df["AUC.hier"])
        rocValsFS.append(curr_df[curr_df["fs"] == "FS"]["AUC.hier"])
        rocValsPCA.append(curr_df[curr_df["fs"] == "PCA"]["AUC.hier"])
    print(names)
    prcVals = [PRCflat]+prcVals
    rocVals = [AUCflat]+rocVals
    prcValsFS = [PRCflatFS]+prcValsFS
    prcValsPCA = [PRCflatPCA]+prcValsPCA
    rocValsFS = [AUCflatFS]+rocValsFS
    rocValsPCA = [AUCflatPCA]+rocValsPCA
    plotData(names, rocVals, "AUROC", "NO_FS")
    plotData(names, prcVals, "AUPRC", "NO_FS")
    plotData(names, prcValsFS, "AUPRC", "FS")
    plotData(names, prcValsPCA, "AUPRC", "PCA")
    plotData(names, rocValsFS, "AUROC", "FS")
    plotData(names, rocValsPCA, "AUROC", "PCA")
