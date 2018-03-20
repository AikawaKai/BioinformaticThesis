
path_results <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/MLFeatureSelection/scores_variance/CC_results/CC_variance_90/variance_90_"
ends <- "10fcv.rda"
perf <- "perf"
algorithms <- c("mlp", "xgbLinear", "svmLinear", "svmRadial", "glmnet", "C5.0", "lda",
                "rf", "AdaBoost.M1", "LogitBoost", "gaussprPoly", "treebag", "knn")
dataFrameAUC <- data.frame()
dataFramePRC <- data.frame()
index <- 1
for(i in seq(1:length(algorithms))){
  algo <- algorithms[[i]]
  perfPath <- paste(path_results, algo, ".", perf, ".", ends, sep="")
  tryCatch(
    {
      load(perfPath)
      if(nrow(dataFrameAUC)==0){
        dataFrameAUC <- data.frame(AUC.flat["per.class"])
        dataFramePRC  <- data.frame(PRC.flat["per.class"])
      }else{
        dataFrameAUC <- cbind(dataFrameAUC, algo=AUC.flat["per.class"])
        dataFramePRC <- cbind(dataFramePRC, algo=PRC.flat["per.class"])
      }
      print(algo)
      names(dataFrameAUC)[index] <- algo
      names(dataFramePRC)[index] <- algo
      index = index + 1
    }, error = function(err){
       cat()
      #print(perfPath)
    })
}
dataFrameAUC
dataFramePRC
write.csv(dataFrameAUC, file=paste0(path_results,"auc.csv"))
write.csv(dataFramePRC, file=paste0(path_results,"prc.csv"))

