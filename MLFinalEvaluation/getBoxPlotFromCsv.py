import csv
import sys
import os
import matplotlib.pyplot as plt

# set di colori (si possono modificare a piacimento. Devono essere esattamente 12)
colors = ['red', 'blue', 'green', 'yellow', 'grey',
          'brown', 'pink', 'lightblue', 'lightgreen', 'magenta',
          'gold', 'orangered']


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


# scrive uno specifico box plot su disco, in base ad una key: {times, AUROC, AUPRC, ...}
def write_box_plot(key, list_dicts):
    names = [split_file_name(name.split('.csv')[0]) for name, dict_ in list_dicts]
    type_, ontology, algo = names[0]
    title_ = type_ + "_" + ontology + "_" + key
    names = [n[2] for n in names]
    vals = [[float(val) for val in dict_[key]] for name, dict_ in list_dicts]
    print("#### KEY: {} ####".format(key))
    print(names)
    print(vals)
    fig = plt.figure(figsize=(16, 5))
    ax = fig.add_subplot(111)
    bp = ax.boxplot(vals, patch_artist=True)
    i = 0
    for box in bp['boxes']:
        box.set(facecolor=colors[i])
        i += 1
    ax.set_title(title_)
    if key == "times":
        key = "tempo"
    ax.set_ylabel(key.upper())
    ax.set_xlabel('ALGORITMI')
    ax.set_xticklabels(names)
    changeFontSize(ax, 18, 15, 22)

    plt.savefig(title_ + ".png")


# funzione per la generazione dei divesi box plot
def write_box_plots(list_dicts):
    keys = [key for key, values in list_dicts[0][1].items() if cast_float(values[0])]
    for key in keys:
        write_box_plot(key, list_dicts)


# trasposta di una matrice
def transpose(matrix):
    return [[matrix[i][j] for i in range(len(matrix))] for j in range(len(matrix[0]))]


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


# funzione per estrarre i dati dal csv
def get_data_from_csv(csv_name):
    with open(csv_name, "r") as csv_op:
        reader = csv.reader(csv_op, delimiter="\t")
        rows = [row_ for row_ in reader]
    rows = transpose(rows)
    dict_values = {row_[0]: row_[1:] for row_ in rows}
    return dict_values


# main
if __name__ == '__main__':
    # directory dove si trovano i file csv da caricare in memoria
    directory_ = sys.argv[1]
    files = [(directory_ + "/" + file_, file_) for file_ in os.listdir(directory_)
             if file_.endswith(".csv")]
    list_dicts = []
    for file_, name in files:
        # type_, onto, algo = split_file_name(name)
        dict_result = get_data_from_csv(file_)
        list_dicts.append([name, dict_result])
    list_dicts = sorted(list_dicts, key=lambda x: x[0].lower())
    write_box_plots(list_dicts)

