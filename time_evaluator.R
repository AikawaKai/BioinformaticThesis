library(caret)
source("/home/kai/Documents/Unimi/Tesi-Bioinformatica/MachineLearning_ExecutionTimeEvaluation_R/metrics.R");
datasetpath <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/"

load(file=paste(datasetpath, "/6239_CAEEL/6239_CAEEL_STRING_NET_v10.5.rda", sep = ""))
load(file=paste(datasetpath, "/6239_CAEEL/6239_CAEEL_GO_BP_ANN_STRING_v10.5_20DEC17.rda", sep=""))
y_test <- ann[,1]
string_class_matrix<-cbind(W,y_test)
ntimes <- 10
number.folds = 10
algorithm="svmLinear";
# grid of the parameters to be  tuned:
Grid <-  expand.grid(C=c(0.01,0.05, 0.1, 1, 10));
file.name<-paste0(datasetpath ,"Results/", algorithm, ".rda");  # nome del file in cui vengono memorizzati i risultati.
AUROC <- AUPRC <- conf <- test_set_list <- model <- vector("list", ntimes);
set.seed(1)  # questo assicura che vengano create sempre le stesse partizioni
#test

trainIndex <- createFolds(factor(string_class_matrix[,nrow(string_class_matrix)]), k = number.folds, list = TRUE)
View(caret::train)
for(i in seq(1, number.folds)){
  tc <- trainControl(method = "cv", number = number.folds, classProbs = TRUE, summaryFunction = AUPRCSummary)
  set.seed(2);
  curr_y <- as.factor(y_test[trainIndex[[i]]])
  curr_x <- W[trainIndex[[i]],]
  levels(curr_y)<-c("negative", "positive")
  print("I'm here")
  print(nrow(curr_y))
  print(nrow(curr_x))
  tryCatch({
      model[[i]] <- caret::train(x=curr_x, y=curr_y,
                             method = algorithm, 
                             trControl = tc, 
                             verbose = FALSE, 
                             tuneGrid = Grid,
                             metric = "AUPRC")
  },  error = function(err) {
      print(err)
                             })
  print("Now here")
  # Probabilistic prediction on the test set
  model.prob <- predict(model[[i]], newdata = as.data.frame(W[-trainIndex[[i]],]), type = "prob")
  
  # true labels
  obs <- y_test[-trainIndex[[i]]]
  
  # computing predicted labels at cutoff=0.5
  pred <- factor(ifelse(model.prob$Altered_splicing >= .5, "Altered_splicing", "Unaltered_splicing"), levels=c("Altered_splicing","Unaltered_splicing"));
  # construction of the data frame for evaluating the predictions
  test_set_list[[i]] <- data.frame(obs = obs, pred=pred, Altered_splicing=model.prob$Altered_splicing, Unaltered_splicing=model.prob$Unaltered_splicing); 
  
  test_set <- test_set_list[[i]];
  
  # computing AUROC
  AUROC[[i]] <- twoClassSummary(test_set, lev = levels(test_set$obs));  
  # computing AUPRC
  AUPRC[[i]] <- prSummary(test_set, lev = levels(test_set$obs));     
  
  conf[[i]] <- best.threshold.confusion(test_set, thresholds = seq(0.01, 0.99, by=0.01));
  
  cat("End of iteration ", i, "\n");
}
warnings()
# saving results
save(AUROC, AUPRC, conf, test_set_list, model, file=file.name);
warnings()


