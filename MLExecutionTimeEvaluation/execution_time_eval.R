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

factorToNumeric <- function(x){
  print(levels(x))
  if(levels(x)[[1]]=="positive"){
    levels(x)[[1]] = "1"
    levels(x)[[2]] = "0"
  }else{
    levels(x)[[2]] = "1"
    levels(x)[[1]] = "0"
  }
  x <- as.numeric(levels(x))[x]
  return(x)
}

convertToLabelFactor <- function(obs){
  obs <- as.factor(obs)
  if(levels(obs)[[1]] == "0")
  {
    levels(obs)[[2]] <- "positive"
    levels(obs)[[1]] <- "negative"
  }else{
    levels(obs)[[2]] <- "positive"
    levels(obs)[[1]] <- "negative"
  }
  obs <- relevel(obs, "positive")
  #print(obs)
  return(obs)
}

crossValidation1Fold <- function(number.folds,  W, y_classes, y_names, algorithm, path_, curr_ont_name){
  print(y_names)
  #csv file
  time_file <- paste(path_, algorithm,"_", curr_ont_name, "_time.csv", sep = "")
  eval_file <- paste(path_, algorithm,"_", curr_ont_name, "_AUC_ROC_PRC.csv", sep = "")
  
  #first row
  write(c("algo", "time", "class", "num_pos"), file=time_file, sep=",", ncolumns = 4)
  write(c("iter", "AUROC", "AUPRC"), file=eval_file, sep = ",", ncolumns = 3)
  # time evaluation
  for(j in seq(1, length(y_classes)))
  {
    
    AUROC <- AUPRC <- vector("list", 1);
    y_test <- y_classes[[j]]
    # split with proportions
    indices <- rownames(W)
    positives <- which(y_test == 1)
    #print(positives)
    
    folds <- do.stratified.cv.data.single.class(indices, positives, kk=number.folds, seed=1);
    trainIndex <- mapply(c, folds$fold.positives, folds$fold.negatives, SIMPLIFY=FALSE);
    names(trainIndex) <- paste0("Fold", gsub(" ", "0", format(1:number.folds)));
    start.time <- Sys.time()
    # no nested cross validation
    tc <- trainControl(method = "none", classProbs = TRUE)
    # current labels for current training set
    curr_y <- convertToLabelFactor(y_test[-which(rownames(W) %in% trainIndex[[1]])])
    # current training set 
    curr_x <- W[-which(rownames(W) %in% trainIndex[[1]]), ]
    print("curr num label training set:")
    print(length(curr_y))
    print("Curr training set size: ")
    print(nrow(curr_x))
        
    # break to next cicle if there are not positives in the current training set
    # learning model
    print(curr_y)
    model <- caret::train(curr_x, curr_y,
                          method = algorithm, 
                          trControl = tc, 
                          #tuneGrid = Grid,
                          metric = "AUPRC")
    # current test_set
    print("here?")
    curr_test_set <- W[which(rownames(W) %in% trainIndex[[1]]),]
    print("curr test set size:")
    print(nrow(curr_test_set))
        
    # prediction on test set with trained model
    model.prob <- predict(model, newdata = curr_test_set, type = "prob")
    # true labels
    obs <- convertToLabelFactor(y_test[which(rownames(W) %in% trainIndex[[1]])])
        
    # predicted labels (cutoff 0.5)
    pred <- factor(ifelse(model.prob$positive >= .5, "positive", "negative"), levels = levels(obs));
    #print(pred)
        
    # construction of the data frame for evaluating the predictions
    test_set <- data.frame(obs = obs, pred=pred, positive=as.numeric(model.prob$positive), negative=as.numeric(model.prob$negative)); 
    #print(test_set)
    # computing AUROC
    tryCatch({
      print(AUC(model.prob$positive, factorToNumeric(obs)))
      print(twoClassSummary(test_set, lev = levels(test_set$obs))[[1]])
      AUROC[[1]] <- twoClassSummary(test_set, lev = levels(test_set$obs))}, 
      error = function(err) {
        print(paste("MY_ERROR:  ",err))
        AUROC[[1]] <-twoClassSummary(test_set, lev = levels(test_set$obs))
    })
        
    # computing AUPRC
    tryCatch({
      print(PRAUC(model.prob$positive, factorToNumeric(obs)))
      print(prSummary(test_set, lev = levels(test_set$obs))[[1]])
      AUPRC[[1]] <- prSummary(test_set, lev = levels(test_set$obs))}, 
      error = function(err) {
        print(paste("MY_ERROR:  ",err))
        AUPRC[[1]] <- prSummary(test_set, lev = levels(test_set$obs))
    })  
    cat("End of iteration ", 1, "\n");
    #print(AUROC[[i]])
    #print(AUPRC[[i]])
    rm(model)
    rm(test_set)
    gc()
    end.time <- Sys.time()
    time.taken <- end.time - start.time
    write(c(algorithm, time.taken*10, y_names[[j]], length(which(y_test==1))), file=time_file, 
          sep=",", append = "TRUE", ncolumns = 4)
    for(i in seq(1,1)){
      write(c(i, AUROC[[1]][[1]], AUPRC[[1]][[1]]), file=eval_file, sep = ",", append = TRUE, ncolumns = 3)
    }
    rm(AUPRC)
    rm(AUROC)
    rm(trainIndex)
    gc()
  }
} 

path_ <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/" #where to write csv
datasetpath <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/" #where to extract data
#STRING SIMILARITY MATRIX
load(file=paste(datasetpath, "/6239_CAEEL/6239_CAEEL_STRING_NET_v10.5.rda", sep = ""))

# only when testing
W <- W[seq(1,1200),]

W <- apply(W, FUN= function(x) x/1000, MARGIN = c(1,2))
ontologies <- c("/6239_CAEEL/6239_CAEEL_GO_BP_ANN_STRING_v10.5_20DEC17.rda",
                #"/6239_CAEEL/6239_CAEEL_GO_MF_ANN_STRING_v10.5_20DEC17.rda",
                "/6239_CAEEL/6239_CAEEL_GO_CC_ANN_STRING_v10.5_20DEC17.rda")

ont_name <- c("BP", "MF", "CC")
for(i in seq(1,3)){
  curr_ont_name <- ont_name[[i]]
  print("#################")
  print("ONTOLOGY")
  load(file=paste(datasetpath, ontologies[[i]], sep=""))
  print(ontologies[[i]])
  set.seed(2)
  ann_select <-ann[,colSums(ann)>9]
  ann_sample <- sample(colnames(ann_select), 10)
  print(ann_sample)
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
    new_sub_sample[[i]] <- sub_sample[seq(1,1200),i]
  }
  y_classes <- new_sub_sample
  
  rm(sub_sample)
  
  
  # algorithms
  algorithms <- c("svmLinear")#, "mlpML", 
  #"AdaBoost.M1", "rf", "C5.0", "xgbLinear",
  #"lda", "LogitBoost", "gaussprPoly", "glmnet",
  #"randomGLM", "treebag", "knn")
  
  # cross validation and parallelization params
  number.folds <- 10
  no_cores <- detectCores() -1
  cl <- makeCluster(no_cores, errfile="./errParSeq.txt", outfile=paste(path_, "out.txt", sep=""), type = "FORK")
  
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
  
  out<-parLapply(cl, algorithms, function(x) c(crossValidation1Fold(number.folds, W, 
                                                               y_classes, ann_sample, 
                                                               x, path_, curr_ont_name)))
  stopCluster(cl)
  #crossValidation(number.folds, ntimes, trainIndex, W, y_test, "svmLinear")
  rm(y_classes)
  rm(ann_sample)
  gc()
  #showMemoryUse()
}
