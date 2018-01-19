library(caret)
source("/home/kai/Documents/Unimi/Tesi-Bioinformatica/MachineLearning_ExecutionTimeEvaluation_R/metrics.R");
datasetpath <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/"

load(file=paste(datasetpath, "/6239_CAEEL/6239_CAEEL_STRING_NET_v10.5.rda", sep = ""))
load(file=paste(datasetpath, "/6239_CAEEL/6239_CAEEL_GO_BP_ANN_STRING_v10.5_20DEC17.rda", sep=""))
y_test <- ann[,1]
Grid <-  expand.grid(size=c(2,5,10,15,20,40));
string_class_matrix<-cbind(W,y_test)
ntimes <- 10
number.folds = 10
algorithm="mlp"
file.name<-paste0(datasetpath ,"Results/", algorithm, ".rda");  # nome del file in cui vengono memorizzati i risultati.
AUROC <- AUPRC <- conf <- test_set_list <- model <- vector("list", ntimes);
set.seed(1)  # questo assicura che vengano create sempre le stesse partizioni
#test
seq_test <- seq(1,2000)
string_class_matrix <- string_class_matrix[seq_test,]
y_test <- y_test[seq_test]
W <- W[seq_test,]
trainIndex <- createFolds(factor(string_class_matrix[,nrow(string_class_matrix)]), k = number.folds, list = TRUE)

factor(y_test[trainIndex[[1]]])

for(i in seq(1, number.folds)){
  tc <- trainControl(method = "cv", number = number.folds, classProbs = TRUE, summaryFunction = AUPRCSummary)
  set.seed(2);
  curr_y <- as.factor(y_test[trainIndex[[i]]])
  levels(curr_y)<-c("negative", "positive")
  model[[i]] <- train(x=as.data.frame(W[trainIndex[[i]],]), y=curr_y,
                             method = algorithm, 
                             trControl = tc, 
                             verbose = FALSE, 
                             tuneGrid = Grid,
                             metric = "AUPRC");

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

# saving results
save(AUROC, AUPRC, conf, test_set_list, model, file=file.name);

quit(save="no")


