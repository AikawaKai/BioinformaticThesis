library(caret)
source("/home/kai/Documents/Unimi/Tesi-Bioinformatica/metrics.R");
datasetpath <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/6239_CAEEL/"

load(file=paste(datasetpath, "6239_CAEEL_STRING_NET_v10.5.rda", sep = ""))
load(file=paste(datasetpath, "6239_CAEEL_GO_BP_ANN_STRING_v10.5_20DEC17.rda", sep=""))
y_test <- ann[,1]
string_class_matrix<-cbind(W,y_test)
number.folds = 10
algorithm="mlp"
set.seed(1)  # questo assicura che vengano create sempre le stesse partizioni
res <- createFolds(factor(string_class_matrix[,nrow(string_class_matrix)]), k = number.folds, list = TRUE)
for(i in seq(1,number.folds)){
  tc <- trainControl(method = "cv", number = number.folds, classProbs = TRUE, summaryFunction = AUPRCSummary)
}