library(caret)
library(dplyr)
library(parallel)
library(HEMDAG)
library(MLmetrics)

crossValidation <- function(number.folds,  W, y_classes, y_names, algorithm){

  #csv file
  time_file <- paste(datasetpath, algorithm, "_time.csv", sep = "")
  eval_file <- paste(datasetpath, algorithm, "_AUC_ROC_PRC.csv", sep = "")
  
  #first row
  write(c("algo", "time", "class", "num_pos"), file=time_file, sep=",", ncolumns = 4)
  write(c("iter", "AUROC", "AUPRC"), file=eval_file, sep = ",", ncolumns = 3)
  # time evaluation
  for(j in seq(1, length(y_classes)))
  {
    AUROC <- AUPRC <- test_set_list <- model <- vector("list", number.folds);
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
        model[[i]] <- caret::train(curr_x, curr_y,
                                   method = algorithm, 
                                   trControl = tc, 
                                   #tuneGrid = Grid,
                                   metric = "AUPRC")
        
        
        # current test_set
        curr_test_set <- as.matrix(W[which(rownames(W) %in% trainIndex[[i]]),])
        print("curr test set size:")
        print(nrow(curr_test_set))
        
        # prediction on test set with trained model
        model.prob <- predict(model[[i]], newdata = curr_test_set, type = "prob")
        
        # true labels
        obs <- factor(ifelse(y_test[which(rownames(W) %in% trainIndex[[i]])]>=.5, "positive", "negative"), levels=c("positive", "negative"))
        
        # predicted labels (cutoff 0.5)
        pred <- factor(ifelse(model.prob$positive >= .5, "positive", "negative"), levels=c("positive","negative"));
        
        # construction of the data frame for evaluating the predictions
        test_set_list[[i]] <- data.frame(obs = obs, pred=pred, positive=as.numeric(model.prob$positive), negative=as.numeric(model.prob$negative)); 
        test_set <- test_set_list[[i]];
        
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
        gc()
      })
    
    write(c(algorithm, exTime[3], y_names[[j]], length(which(y_test==1))), file=time_file, 
          sep=",", append = "TRUE", ncolumns = 4)
    for(i in seq(1,number.folds)){
      write(c(i, AUROC[[i]][[1]], AUPRC[[i]][[1]]), file=eval_file, sep = ",", append = TRUE, ncolumns = 3)
    }
    rm(AUPRC)
    rm(AUROC)
    rm(model)
    rm(test_set_list)
    gc()
  }
} 

source("/home/kai/Documents/Unimi/Tesi-Bioinformatica/MachineLearning_ExecutionTimeEvaluation_R/metrics.R");

datasetpath <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/"
load(file=paste(datasetpath, "/6239_CAEEL/6239_CAEEL_STRING_NET_v10.5.rda", sep = ""))
load(file=paste(datasetpath, "/6239_CAEEL/6239_CAEEL_GO_BP_ANN_STRING_v10.5_20DEC17.rda", sep=""))

set.seed(1)
ann_select <-ann[,colSums(ann)>9]
ann_sample <- sample(colnames(ann_select), 20)
classes <- ann_select[,ann_sample]

y_classes <- list(length(classes))
for(i in seq(1,length(y_classes))){
  y_classes[[i]] <- classes[,i]
}

# only when testing
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
algorithms <- c("svmLinear", "svmRadial") #, "mlp", "mlpML", 
                #"AdaBoost.M1", "rf", "C5.0", "xgbLinear",
                #"lda", "LogitBoost", "gaussprPoly", "glmnet",
                #"randomGLM", "treebag", "knn")

# cross validation and parallelization params
number.folds <- 10
no_cores <- detectCores() -1
cl <- makeCluster(no_cores, errfile="./errParSeq.txt", outfile="./out.txt")

# import functions for parallelization
clusterExport(cl, list("crossValidation", "number.folds",
                       "trainControl", "AUPRCSummary", "y_classes",
                       "W", "predict","compute.AUPRC",
                       "evalmod", "datasetpath", "twoClassSummary",
                       "prSummary", "do.stratified.cv.data.single.class",
                       "ann_sample"))


rm(ann)
rm(ann_select)
rm(classes)
gc()

out<-parLapply(cl, algorithms, function(x) c(crossValidation(number.folds, as.data.frame(W), 
                                                             y_classes, ann_sample, x)))
stopCluster(cl)
#crossValidation(number.folds, ntimes, trainIndex, W, y_test, "svmLinear")
