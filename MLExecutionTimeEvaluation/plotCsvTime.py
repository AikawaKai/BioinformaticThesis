import os, csv, sys
from numpy import mean, std
import pandas as pd
import matplotlib as mpl
mpl.use('agg')
import matplotlib.pyplot as plt

colors = ["red", "blue", "green", "yellow", "xkcd:sky blue", "brown", "pink", "grey",
          "grey", "grey", "grey", "grey", "grey", "grey", "grey", "grey",
          "grey"]

algos = ["svmLinear", "svmRadial", "LogitBoost", "C5.0", "mlp", "xgbLinear", "AdaBoost_M1", "knn", "glmnet", "rf"]
classes = ["BP", "CC", "MF"]

def plotBoxPlot(class_, files):
    dataframes = [pd.read_csv(csv) for csv in files]
    times_ = dict()
    print([df["algo"] for df in  dataframes])
    for dataframe in dataframes:
        try:
            algo = dataframe["algo"][0]
        except:
            print("UOPS", dataframe["algo"])
        times_[algo] = [dataframe["time"].values]
    for key, value in times_.items():
        print(key)
        max_val = max(value[0])
        min_val = min(value[0])
        mean_val = mean(value[0])
        std_val = std(value[0])
        print("max: ", max_val)
        print("min: ", min_val)
        print("mean: ", mean_val)
        print("std: ", std_val)
        times_[key]+=[max_val, min_val, mean_val, std_val]
    names = [key for key, values in times_.items()]
    print(names)
    box_plot_values = [val[0]/3600 for key, val in times_.items()]
    print(box_plot_values)
    '''
    if len(box_plot_values)<15:
        len_ = 15 - len(box_plot_values)
        for i in range(len_):
            box_plot_values.append([0])
            names.append("to_do")'''
    saveBoxPlot(class_, box_plot_values, names)
    first_row = ["algo", "max_time", "min_time", "mean_time", "std_time"]
    with open("./{}times_.csv".format(class_), "w") as f_:
        wr = csv.writer(f_, delimiter= ",")
        wr.writerow(first_row)
        for key, value in times_.items():
            wr.writerow([key, round(value[1]/3600,2), round(value[2]/3600, 2),
                         round(value[3]/3600, 2), round(value[4]/3600, 2)])

def saveBoxPlot(class_name, list_data, list_names):
    fig = plt.figure(1, figsize=(20, 8))
    print(list_names)
    plt.xlabel("Algorithms", fontsize=15)
    plt.ylabel("Time", fontsize=15)
    boxes = plt.boxplot(list_data, patch_artist=True)
    i=0
    for box in boxes["boxes"]:
        box.set_facecolor(colors[i])
        i+=1
    plt.xticks([i for i in range(1, len(list_names)+1)], list_names)
    plt.tick_params(labelsize=13)
    # Save the figure
    fig.savefig('{}_box_plot_times.png'.format(class_name), bbox_inches='tight')
    fig.clf()

def composeName(algo, class_):
    return algo+"_"+class_+"_"+"time.csv"

def splitCsvInClasses(csv_list, path):
    all_csv_times = {cl:[] for cl in classes}
    for class_ in classes:
        for algo in algos:
            name = composeName(algo, class_)
            if name in csv_list:
                all_csv_times[class_].append(path+name)
    return all_csv_times

if __name__ == '__main__':
    path = "./Time_results/"
    csv_ = os.listdir(path)
    all_csv_times = splitCsvInClasses(csv_, path)

    for class_, files in all_csv_times.items():
        plotBoxPlot(class_, files)
