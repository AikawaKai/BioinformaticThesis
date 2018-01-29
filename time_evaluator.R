library(caret)
library(dplyr)
library(parallel)
library(HEMDAG)
library(MLmetrics)

showMemoryUse <- function(sort="size", decreasing=FALSE, limit) {
  
  objectList <- ls(parent.frame())
  
  oneKB <- 1024
  oneMB <- 1048576
  oneGB <- 1073741824
  
  memoryUse <- sapply(objectList, function(x) as.numeric(object.size(get(x, parent.frame()))))
  
  memListing <- sapply(memoryUse, function(size) {
    if (size >= oneGB) return(paste(round(size/oneGB,2), "GB"))
    else if (size >= oneMB) return(paste(round(size/oneMB,2), "MB"))
    else if (size >= oneKB) return(paste(round(size/oneKB,2), "kB"))
    else return(paste(size, "bytes"))
  })
  
  memListing <- data.frame(objectName=names(memListing),memorySize=memListing,row.names=NULL)
  
  if (sort=="alphabetical") memListing <- memListing[order(memListing$objectName,decreasing=decreasing),] 
  else memListing <- memListing[order(memoryUse,decreasing=decreasing),] #will run if sort not specified or "size"
  
  if(!missing(limit)) memListing <- memListing[1:limit,]
  
  print(memListing, row.names=FALSE)
  return(invisible(memListing))
}

crossValidation <- function(number.folds,  W, y_classes, y_names, algorithm){
  path_ <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/"
  #csv file
  time_file <- paste(path_, algorithm, "_time.csv", sep = "")
  eval_file <- paste(path_, algorithm, "_AUC_ROC_PRC.csv", sep = "")
  
  #first row
  write(c("algo", "time", "class", "num_pos"), file=time_file, sep=",", ncolumns = 4)
  write(c("iter", "AUROC", "AUPRC"), file=eval_file, sep = ",", ncolumns = 3)
  # time evaluation
  for(j in seq(1, length(y_classes)))
  {
    AUROC <- AUPRC <- vector("list", number.folds);
    y_test <- y_classes[[j]]
    # split with proportions
    indices <- rownames(W)
    positives <- which(y_test == 1)
    print(positives)
    
    folds <- do.stratified.cv.data.single.class(indices, positives, kk=number.folds, seed=1);
    trainIndex <- mapply(c, folds$fold.positives, folds$fold.negatives, SIMPLIFY=FALSE);
    names(trainIndex) <- paste0("Fold", gsub(" ", "0", format(1:number.folds)));
    exTime <- system.time(
      for(i in seq(1, number.folds)){
        # no nested cross validation
        tc <- trainControl(method = "none", classProbs = TRUE)
        
        # current labels for current training set
        curr_y <- y_test[-which(rownames(W) %in% trainIndex[[i]])]
        curr_y <- as.factor(curr_y)
        levels(curr_y)<-c("negative", "positive")
        
        # current training set 
        curr_x <- W[-which(rownames(W) %in% trainIndex[[i]]), ]
        print("curr num label training set:")
        print(length(curr_y))
        print("Curr training set size: ")
        print(nrow(curr_x))
        
        # break to next cicle if there are not positives in the current training set
        if(length(unique(curr_y))<=1){
          print("empty")
          next
        }
        # learning model
        model <- caret::train(curr_x, curr_y,
                              method = algorithm, 
                              trControl = tc, 
                              #tuneGrid = Grid,
                              metric = "AUPRC")
        
        
        # current test_set
        curr_test_set <- as.matrix(W[which(rownames(W) %in% trainIndex[[i]]),])
        print("curr test set size:")
        print(nrow(curr_test_set))
        
        # prediction on test set with trained model
        model.prob <- predict(model, newdata = curr_test_set, type = "prob")
        
        # true labels
        obs <- factor(ifelse(y_test[which(rownames(W) %in% trainIndex[[i]])]>=.5, "positive", "negative"), levels=c("positive", "negative"))
        
        # predicted labels (cutoff 0.5)
        pred <- factor(ifelse(model.prob$positive >= .5, "positive", "negative"), levels=c("positive","negative"));
        
        # construction of the data frame for evaluating the predictions
        test_set <- data.frame(obs = obs, pred=pred, positive=as.numeric(model.prob$positive), negative=as.numeric(model.prob$negative)); 
        
        # computing AUROC
        tryCatch({AUROC[[i]] <- twoClassSummary(test_set, lev = levels(test_set$obs))}, 
                 error = function(err) {
                   print(paste("MY_ERROR:  ",err))
                 })
        
        # computing AUPRC
        tryCatch({AUPRC[[i]] <- prSummary(test_set, lev = levels(test_set$obs))}, 
                 error = function(err) {
                   print(paste("MY_ERROR:  ",err))
                 })  
        cat("End of iteration ", i, "\n");
        print(AUROC[[i]][[1]])
        print(AUPRC[[i]][[1]])
        rm(model)
        rm(test_set)
        gc()
      })
    
    write(c(algorithm, exTime[3], y_names[[j]], length(which(y_test==1))), file=time_file, 
          sep=",", append = "TRUE", ncolumns = 4)
    for(i in seq(1,number.folds)){
      write(c(i, AUROC[[i]][[1]], AUPRC[[i]][[1]]), file=eval_file, sep = ",", append = TRUE, ncolumns = 3)
    }
    rm(AUPRC)
    rm(AUROC)
    gc()
  }
} 

source("/home/kai/Documents/Unimi/Tesi-Bioinformatica/MachineLearning_ExecutionTimeEvaluation_R/metrics.R");

datasetpath <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/"
load(file=paste(datasetpath, "/6239_CAEEL/6239_CAEEL_STRING_NET_v10.5.rda", sep = ""))
load(file=paste(datasetpath, "/6239_CAEEL/6239_CAEEL_GO_BP_ANN_STRING_v10.5_20DEC17.rda", sep=""))

set.seed(1)
ann_select <-ann[,colSums(ann)>9]
ann_sample <- sample(colnames(ann_select), 10)
classes <- ann_select[,ann_sample]

y_classes <- list(10)
for(i in seq(1, 10)){
  y_classes[[i]] <- classes[,i]
}

#only when testing
sub_sample <- classes[,seq(1,2)]
ann_sample <- ann_sample[seq(1,2)]
new_sub_sample <- list(2)
for(i in seq(1,2)){
  new_sub_sample[[i]] <- sub_sample[seq(1,1000),i]
}
y_classes <- new_sub_sample
W <- W[seq(1,1000),]
rm(sub_sample)

W <- apply(W, FUN= function(x) x/1000, MARGIN = c(1,2))

# algorithms
algorithms <- c("svmLinear", "svmRadial", "mlp")#, "mlpML", 
#"AdaBoost.M1", "rf", "C5.0", "xgbLinear",
#"lda", "LogitBoost", "gaussprPoly", "glmnet",
#"randomGLM", "treebag", "knn")

# cross validation and parallelization params
number.folds <- 10
no_cores <- detectCores() -1
cl <- makeCluster(no_cores, errfile="./errParSeq.txt", outfile="./out.txt", type = "FORK")

# import functions for parallelization
#clusterExport(cl, list("crossValidation", "number.folds",
#                       "trainControl", "AUPRCSummary", "y_classes",
#                       "W", "predict","compute.AUPRC",
#                       "evalmod", "datasetpath", "twoClassSummary",
#                       "prSummary", "do.stratified.cv.data.single.class",
#                       "ann_sample"))


rm(ann)
rm(ann_select)
rm(classes)
gc()

out<-parLapply(cl, algorithms, function(x) c(crossValidation(number.folds, as.data.frame(W), 
                                                             y_classes, ann_sample, x)))
stopCluster(cl)
#crossValidation(number.folds, ntimes, trainIndex, W, y_test, "svmLinear")
showMemoryUse()
