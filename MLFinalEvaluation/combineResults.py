import sys, os, csv
import pandas as pd
from numpy import mean, std

def parseCsvName(filename):
    parsed = filename.split(".csv")[0].split("_")
    if len(parsed) == 4:
        type_, onto, naive, bayes = parsed
        algo = "naive_bayes"
        return [type_, onto, algo]
    return parsed

def getRowsFromDataFrame(curr_dataframe, filename):
    type_, onto, algo = parseCsvName(filename)
    num_rows, num_col = curr_dataframe.shape
    indexes = [i for i in range(10, num_rows, 11)]
    curr_dataframe = curr_dataframe.iloc[indexes,:]
    new_rows = []
    aurocs = []
    auprcs = []
    times = []
    for row_index, row in curr_dataframe.iterrows():
        list_row = list(row)
        new_rows.append([onto, list_row[0], algo, type_] +[round(val,4) for val in list_row[1:]])
        aurocs+=[list_row[1]]
        auprcs+=[list_row[2]]
        times+=[list_row[3]]
    aggregate_row = [onto, algo, type_, round(mean(aurocs),4), round(mean(auprcs),4), round(mean(times)/3600,4), round(sum(times)/3600,4)]
    return new_rows, aggregate_row

def loadDataFromCsv(path):
    csv_files = [(file_, path+file_) for file_ in os.listdir(path) if file_.endswith(".csv")]
    print(csv_files)
    new_rows = []
    new_aggregate_rows = []
    for filename, file_ in csv_files:
        curr_dataframe = pd.read_csv(file_)
        rows, aggregate_row = getRowsFromDataFrame(curr_dataframe, filename)
        new_rows+=rows
        new_aggregate_rows.append(aggregate_row)
    return new_rows, new_aggregate_rows

if __name__ == '__main__':
    csv_path = sys.argv[1]
    PCA_path = csv_path+"/PCA/"
    FS_path = csv_path+"/FS/"
    rows_pca, aggregate_rows_pca = loadDataFromCsv(PCA_path)
    rows_fs, aggregate_rows_fs = loadDataFromCsv(FS_path)
    rows_pca+=rows_fs
    aggregate_rows_pca+=aggregate_rows_fs
    with open("results.csv", "w") as f_w:
        writer = csv.writer(f_w, delimiter=",")
        header = ["ontology", "class", "algorithm", "selection_type", "auroc", "auprc", "time_sec"]
        tot_rows = [header]+rows_pca
        writer.writerows(tot_rows)
    with open("resultsAggregate.csv", "w") as f_w:
        writer = csv.writer(f_w, delimiter=",")
        header = ["ontology", "algorithm", "selection_type", "auroc", "auprc", "mean_time_hours", "tot_time_hours"]
        tot_rows = [header]+aggregate_rows_pca
        writer.writerows(tot_rows)
