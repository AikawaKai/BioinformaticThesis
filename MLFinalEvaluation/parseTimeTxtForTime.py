import csv, sys, os
from numpy import mean

dict_num_ann = {"BP":1335, "MF":186, "CC":221}

if __name__ == '__main__':
    dir_ = sys.argv[1]

    files = [file_ for file_ in os.listdir(dir_) if file_ not in ["times", "old_times"]]
    print(files)
    rows = []
    for file_ in files:
        algo, onto, FS = file_.split("_")
        print(algo, onto, FS)
        times = []
        with open(dir_+file_, "r") as file_r:
            for line in file_r:
                print(line)
                sec = float(line.split(" sec ")[0].split("ELAPSED TIME:")[1])
                times.append(sec)
        row = [algo, onto, round(mean(times)/3600, 2),
               round((mean(times)/3600) * dict_num_ann[onto], 2)]
        rows.append(row)
    with open("new.csv", "w") as file_w:
        writer = csv.writer(file_w, delimiter = ",")
        writer.writerows(rows)
    '''
    with open("LogitBoost_MF_FS", "w") as file_w:
        writer = csv.writer(file_w, delimiter = ",")
        writer.writerow(["LogitBoost", "MF", round(mean(times)/3600, 2),
                         round((mean(times)/3600) * dict_num_ann["MF"], 2)])'''
