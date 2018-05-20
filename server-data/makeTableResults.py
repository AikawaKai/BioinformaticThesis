import os, csv, pandas, copy
from numpy import mean

algos = ["mlp", "lda", "AdaBoost.M1", "knn", "LogitBoost", "xgbLinear", "rf",
         "C5.0", "svmLinear", "svmRadial", "glmnet", "gaussprPoly", "treebag"]

def getRowFromDicts(algo, auroc, auprc, times):
    roc_val = auroc[algo]
    prc_val = auprc[algo]
    time_val = times[algo]
    print(algo)
    roc_val_m = round(mean(roc_val),4)
    prc_val_m = round(mean(prc_val),4)
    time_val_m = round(mean(time_val),2)
    return [prc_val_m, roc_val_m, time_val_m, round(time_val_m/3600,3)]

def getAuPrcScoreXAlgo(score_path):
    auc_file = score_path+"/prc.csv"
    auc_data = pandas.read_csv(auc_file)
    classes = auc_data["Unnamed: 0"]
    algos_vals = dict()
    for algo in algos:
        try:
            algos_vals[algo] =  list(auc_data[algo])
        except:
            print(algo, " not found!")
    return algos_vals

def getAuRocScoreXAlgo(score_path):
    auc_file = score_path+"/auc.csv"
    auc_data = pandas.read_csv(auc_file)
    classes = auc_data["Unnamed: 0"]
    algos_vals = dict()
    for algo in algos:
        try:
            algos_vals[algo] = list(auc_data[algo])
        except:
            print(algo, " not found!")
    return algos_vals

def getTimesFromPath(path):
    dict_times = dict()
    for algo in algos:
        try:
            try:
                data_frame = pandas.read_csv(path+"/"+algo+".csv")
            except Exception as e:
                type_ = path.split("/")[-1]
                file_name = path+"/"+type_+"_"+algo+".csv"
                data_frame = pandas.read_csv(file_name)
            dict_times[algo]=list(data_frame.iloc[:,1])
        except:
            print(algo, " not found!")
    return dict_times

if __name__ == '__main__':
    path_score = "./score/"
    path_time = "./time/"
    scores_dir = [path_score+file_ for file_ in os.listdir(path_score)]
    times_dir = [path_time+file_ for file_ in os.listdir(path_time)]
    path_x_variance = [file_ for file_ in zip(scores_dir, times_dir)]
    dict_variance_score = dict()
    for score_path, time_path in path_x_variance:
        try:
            auroc_score_x_algo = getAuRocScoreXAlgo(score_path)
            auprc_score_x_algo = getAuPrcScoreXAlgo(score_path)
            variance = score_path.split("variance_")[1]
            print("###############", variance)
            print("AUROC")
            #print(auroc_score_x_algo)
            print("AUPRC")
            #print(auprc_score_x_algo)
            times_x_algo = getTimesFromPath(time_path)
            for key in ["CC", "MF", "BP"]:
                if key in score_path:
                    dict_variance_score[key+"_"+variance] = (auroc_score_x_algo,
                                                          auprc_score_x_algo,
                                                          times_x_algo)
        except Exception as e:
            print(e)
            print(score_path, time_path)

    variances = [("50", 15), ("70", 100), ("90", 1000)]

    rows = []
    header = ["org", "onto", "model", "variance", "feature", "PRC", "ROC", "sec.", "hour"]
    basic_row = ["6239_CAEEL"]
    with open("./results.csv", "w") as file_csv:
        writer = csv.writer(file_csv, delimiter=",")
        writer.writerow(header)
        for var, num_feat in variances:
            for key in ["CC", "MF", "BP"]:
                (auroc, auprc, times) = dict_variance_score[key+"_"+var]
                for algo in algos:
                    try:
                        new_row = basic_row + [key] + [algo, var, num_feat]
                        curr_row = getRowFromDicts(algo, auroc, auprc, times)
                        curr_row = new_row+curr_row
                        print(curr_row)
                        writer.writerow(curr_row)
                    except Exception as e:
                        print(algo, " not found!")
