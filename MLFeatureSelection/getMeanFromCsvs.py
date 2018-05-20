import csv, sys
from numpy import mean

def transpose(matrix):
    rows = len(matrix)
    cols = len(matrix[0])
    return [[matrix[i][j] for i in range(rows)] for j in range(cols)]

if __name__ == '__main__':
    file_ = sys.argv[1]
    with open(file_, "r") as f_:
        read = csv.reader(f_, delimiter=",")
        lines = [line for line in read]
    tr = transpose(lines)
    head = [tr[0]+["mean"]]
    for algo in tr[1:]:
        name = algo[0]
        vals = algo[1:]
        mean_ = mean([float(v) for v in algo[1:]])
        new_res = [name]+vals+[mean_]
        head.append(new_res)
    print(head)
    matrix = transpose(head)
    print(matrix)
    with open(file_.split(".csv")[0]+"1.csv", "w") as f_:
        wr = csv.writer(f_, delimiter=",")
        for row in matrix:
            print(row)
            wr.writerow(row)
