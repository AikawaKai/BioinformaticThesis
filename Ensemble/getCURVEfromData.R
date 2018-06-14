library(PerfMeas)
path <- "/home/kai/Documenti/UNIMI/BioinformaticThesis/Ensemble/hierPerf/"
path2 <- "/home/kai/Documenti/UNIMI/BioinformaticThesis/Ensemble/"
ontos <- c("BP", "MF", "CC")
methods <- c("flat", "HTD", "GPAV", "TPR-DAGthreshold.free", "ISO-TPRthreshold.free", "TPR-DAGthreshold")
algorithms <- c("adaboost", "C5.0", "glmnet", "kknn", "lda", "LogitBoost", "mlp", 
                "naive_bayes", "ranger", "svmLinear2", "treebag", "xgbLinear")
fs_ <- c("feature", "PCA")

plotData <- function(onto, fs, algo, files, path){
  m <- matrix(nrow = 6, ncol = 10)
  i <- 1
  for(file in files){
    i = i + 1
    load(file)
    PXR.hier <- get('PXR.hier')
    m[i, 1:10] <- PXR.hier$avgPXR
  }
  PXR.flat <- get('PXR.flat')
  m[1, 1:10] <- PXR.flat$avgPXR 
  print(m)
  performance.curves.plot(m, curve.names = methods, y.range = c(0, 0.7), pos=c(0.6, 0.7), 
                          cex.val = 2.2, height = 10, width = 15, f = paste0(path, onto,"_", fs, "_", algo))

}

for(onto in ontos){
  for(fs in fs_){
    for(algo in algorithms){
      print("\n########")
      curr_files <- c(12)
      i <- 0
      for(curr_method in methods[2:length(methods)]){
        i <- i + 1
        path_ <- paste0(path, curr_method, "/")
        files <- list.files(path = path_, recursive = TRUE)
        files <- files[lapply(files, function(x){grepl(".rda", x)})==TRUE]
        files <- files[lapply(files, function(x){grepl(paste0(".", onto, "."), x)})==TRUE]
        files <- files[lapply(files, function(x){grepl(paste0(".", fs, "."), x)})==TRUE]
        files <- files[lapply(files, function(x){grepl(paste0(".", algo, "."), x)})==TRUE]
        curr_files[i] <- paste0(path_, files[[1]])
      }
      # print(curr_files)
      plotData(onto, fs, algo, curr_files, paste0(path2,"plotAUPRC/"))
      print("\n########")
    }
  }  
}
