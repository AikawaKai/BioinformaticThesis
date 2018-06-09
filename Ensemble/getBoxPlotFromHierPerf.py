import pandas as pd
import os

def box_plot_function(curr_path, algo):
    files = [(curr_path+file_, file_) for file_ in os.listdir(curr_path) if file_.endswith(".csv") and file_ != algo+".csv"]
    print(files)
    for file_, file_name in files:
        file_name = file_name.split(".csv")[0]
        print(file_name)
        pd.read_csv(file_)

algo_done = ["TPR-DAGthreshold.free", "ISO-TPRthreshold.free", "GPAV", "HTD"]

if __name__ == '__main__':
    path_ = "/home/kai/Documenti/UNIMI/BioinformaticThesis/Ensemble/hierPerf"
    for algo in algo_done:
        curr_path = path_+"/"+algo+"/"
        box_plot_function(curr_path, algo)

