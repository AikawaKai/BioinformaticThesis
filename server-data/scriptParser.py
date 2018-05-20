import sys, csv, os

if __name__ == '__main__':
    path = sys.argv[1]
    files = os.listdir(path)
    files = [path+"/"+file_ for file_ in files if "out" in file_]
    for file_ in files:
        rows = []
        with open(file_, "r") as f_r:
            lines = [line for line in f_r if "GO class " in line]
            for line in lines:
                class_name = line.split("( ")[1].split(" )")[0]
                time = line.split("DONE ELAPSED TIME:  ")[1]
                rows.append([class_name, float(time)])
        csv_file = file_.split("out")[1]+".csv"
        with open(csv_file, "w") as f_w:
            writer = csv.writer(f_w, delimiter=",")
            for row in rows:
                writer.writerow(row)
