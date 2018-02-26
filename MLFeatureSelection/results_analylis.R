
path_results <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/MLFeatureSelection/results/"
ends <- "10fcv.rda"
perf <- "perf"
algorithms <- c("mlp", "xgbLinear", "svmLinear", "svmRadial", "glmnet", "C5.0")
dataFrameAUC <- data.frame()
dataFramePRC <- data.frame()
for(i in seq(1:length(algorithms))){
  algo <- algorithms[[i]]
  print(algo)
  perfPath <- paste(path_results, algo, ".", perf, ".", ends, sep="")
  load(perfPath)
  if(nrow(dataFrameAUC)==0){
    dataFrameAUC <- data.frame(AUC.flat["per.class"])
    dataFramePRC  <- data.frame(PRC.flat["per.class"])
  }else{
    dataFrameAUC <- cbind(dataFrameAUC, algo=AUC.flat["per.class"])
    dataFramePRC <- cbind(dataFramePRC, algo=PRC.flat["per.class"])
  }
  names(dataFrameAUC)[i] <- algo
  names(dataFramePRC)[i] <- algo
  
}
dataFrameAUC
dataFramePRC
write.csv(dataFrameAUC, file=paste0(path_results,"auc.csv"))
write.csv(dataFramePRC, file=paste0(path_results,"prc.csv"))
