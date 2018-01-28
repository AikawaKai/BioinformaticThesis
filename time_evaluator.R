library(caret)
library(dplyr)
library(parallel)
library(HEMDAG)
library(MLmetrics)

crossValidation <- function(number.folds, ntimes, trainIndex, W, y_test, algorithm){
  AUROC <- AUPRC <- conf <- test_set_list <- model <- vector("list", ntimes);
  
  # time evaluation
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
      
    })
    time_file <- paste(datasetpath, algorithm, "_time.csv", sep = "")
    eval_file <- paste(datasetpath, algorithm, "_AUC_ROC_PRC.csv", sep = "")
    write(algorithm, file=time_file)
    write(exTime[3], file=time_file, append = TRUE)
    
    write(c("iter", "AUROC", "AUPRC"), file=eval_file, sep = ",", ncolumns = 3)
    for(i in seq(1,number.folds)){
      write(c(i, AUROC[[i]][[1]], AUPRC[[i]][[1]]), file=eval_file, sep = ",", append = TRUE)
    }
    
} 

source("/home/kai/Documents/Unimi/Tesi-Bioinformatica/MachineLearning_ExecutionTimeEvaluation_R/metrics.R");

datasetpath <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/"
load(file=paste(datasetpath, "/6239_CAEEL/6239_CAEEL_STRING_NET_v10.5.rda", sep = ""))
load(file=paste(datasetpath, "/6239_CAEEL/6239_CAEEL_GO_BP_ANN_STRING_v10.5_20DEC17.rda", sep=""))
y_test <- ann[,614]


#W <- W[seq(1,1000),]
#y_test <- y_test[seq(1,1000)]
W <- apply(W, FUN= function(x) x/1000, MARGIN = c(1,2))
ntimes <- 10
number.folds <- 10
algorithms <- c("svmLinear", "svmRadial") #, "mlp", "mlpML", 
                #"AdaBoost.M1", "rf", "C5.0", "xgbLinear",
                #"lda", "LogitBoost", "gaussprPoly", "glmnet",
                #"randomGLM", "treebag", "knn")


no_cores <- detectCores() -1
cl <- makeCluster(no_cores, errfile="./errParSeq.txt", outfile="./out.txt")


indices <- rownames(W)
positives <- which(y_test == 1)
print(positives)

folds <- do.stratified.cv.data.single.class(indices, positives, kk=number.folds, seed=1);
trainIndex <- mapply(c, folds$fold.positives, folds$fold.negatives, SIMPLIFY=FALSE);
names(trainIndex) <- paste0("Fold", gsub(" ", "0", format(1:number.folds)));
#trainIndex <- caret::createFolds(factor(y_test), k = number.folds, list = TRUE)

clusterExport(cl, list("crossValidation", "number.folds", "ntimes",
                       "trainControl", "AUPRCSummary", "y_test",
                       "trainIndex", "W", "predict","compute.AUPRC",
                       "evalmod", "datasetpath", "twoClassSummary",
                       "prSummary"))
out<-parLapply(cl, algorithms, function(x) c(crossValidation(number.folds, ntimes, trainIndex, as.data.frame(W), 
                                                             y_test, x)))
#crossValidation(number.folds, ntimes, trainIndex, W, y_test, "svmLinear")
