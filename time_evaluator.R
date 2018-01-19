library(caret)
datasetpath <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/6239_CAEEL/"

load(file=paste(datasetpath, "6239_CAEEL_STRING_NET_v10.5.rda", sep = ""))
load(file=paste(datasetpath, "6239_CAEEL_GO_BP_ANN_STRING_v10.5_20DEC17.rda", sep=""))
y <- ann[,1]

ntimes=10
number.folds = 10
algorithm="mlp"
set.seed(1);  # questo assicura che vengano create sempre le stesse partizioni
trainIndex <- createDataPartition(W, p = .9, list = TRUE,  times = ntimes)
