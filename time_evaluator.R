library(caret)
library(parallel)
crossValidation <- function(number.folds, ntimes, trainIndex, W, y_test, algorithm, string_class_matrix){
  library(caret)
  AUROC <- AUPRC <- conf <- test_set_list <- model <- vector("list", ntimes);
  exTime<-system.time(
  for(i in seq(1, number.folds)){
    tc <- trainControl(method = "cv", number = number.folds, classProbs = TRUE, summaryFunction = AUPRCSummary)
    set.seed(2);
    curr_y <- as.factor(y_test[trainIndex[[i]]])
    curr_x <- as.data.frame(W[trainIndex[[i]],])
    levels(curr_y)<-c("negative", "positive")
    tryCatch({
      model[[i]] <- caret::train(x=curr_x, y=curr_y,
                                 method = algorithm, 
                                 trControl = tc, 
                                 verbose = FALSE, 
                                 #tuneGrid = Grid,
                                 metric = "AUPRC")
    },  error = function(err) {
      print(err)
    })
    # Probabilistic prediction on the test set
    model.prob <- predict(model[[i]], newdata = as.data.frame(W[-trainIndex[[i]],]), type = "prob")
    # true labels
    obs <- y_test[-trainIndex[[i]]]
    # computing predicted labels at cutoff=0.5
    pred <- factor(ifelse(model.prob$positive >= .5, "positive", "negative"), levels=c("positive","negative"));
    # construction of the data frame for evaluating the predictions
    test_set_list[[i]] <- data.frame(obs = obs, pred=pred, positive=model.prob$positive, negative=model.prob$negative); 
    test_set <- test_set_list[[i]];
    # computing AUROC
    #AUROC[[i]] <- twoClassSummary(test_set, lev = levels(test_set$obs));  
    # computing AUPRC
    #AUPRC[[i]] <- prSummary(test_set, lev = levels(test_set$obs));     
    #conf[[i]] <- best.threshold.confusion(test_set, thresholds = seq(0.01, 0.99, by=0.01));
    cat("End of iteration ", i, "\n");
  })
  write(algorithm, file=paste(datasetpath, algorithm, "_time.csv", sep = ""))
  write(exTime[3], file=paste(datasetpath, algorithm, "_time.csv", sep = ""), append = TRUE)
} 

source("/home/kai/Documents/Unimi/Tesi-Bioinformatica/MachineLearning_ExecutionTimeEvaluation_R/metrics.R");

datasetpath <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/"
load(file=paste(datasetpath, "/6239_CAEEL/6239_CAEEL_STRING_NET_v10.5.rda", sep = ""))
load(file=paste(datasetpath, "/6239_CAEEL/6239_CAEEL_GO_BP_ANN_STRING_v10.5_20DEC17.rda", sep=""))
y_test <- ann[,1]
W <- W[seq(1,1000),]
y_test <- y_test[seq(1,1000)]
W <- apply(W, FUN= function(x) x/1000, MARGIN = c(1,2))
string_class_matrix<-cbind(W,y_test)
ntimes <- 2
number.folds = 2
algorithms <- c("svmLinear", "svmRadial") #, "mlp", "mlpML", "AdaBoost.M1", "rf'")

#Grid <-  expand.grid(C = c(.25, .5, 1), sigma = .05);
no_cores <- detectCores() -1
cl <- makeCluster(no_cores, errfile="./errParSeq.txt", outfile="./out.txt")

#vector("list", ntimes);
set.seed(1)  # questo assicura che vengano create sempre le stesse partizioni
trainIndex <- createFolds(factor(string_class_matrix[,nrow(string_class_matrix)]), 
                          k = number.folds, list = TRUE)
clusterExport(cl, list("crossValidation", "number.folds", "ntimes",
                       "trainControl", "AUPRCSummary", "y_test",
                       "trainIndex", "W", "predict","compute.AUPRC",
                       "evalmod", "datasetpath"))
out<-parLapply(cl, algorithms, function(x) c(crossValidation(number.folds, ntimes, trainIndex, W, 
                                                             y_test, x,
                                                             string_class_matrix)))
