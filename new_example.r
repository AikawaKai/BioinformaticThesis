
library(caret);
source("/home/kai/Documents/Unimi/Tesi-Bioinformatica/MachineLearning_ExecutionTimeEvaluation_R/metrics.R");

datasetpath <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/"
load(file=paste(datasetpath, "/6239_CAEEL/6239_CAEEL_STRING_NET_v10.5.rda", sep = ""))
load(file=paste(datasetpath, "/6239_CAEEL/6239_CAEEL_GO_BP_ANN_STRING_v10.5_20DEC17.rda", sep=""))
y_test <- ann[,1]
y_test <- y_test[seq(1,1000)]
W <- W[seq(1,1000),]

string_class_matrix<-cbind(W,y_test)
ntimes=10;  # number of hold - out
number.folds = 10;  # number of folds for the CV on the training set
algorithm="mlp";  # qui viene definito il metodo che si vuole utilizzare (usato dalla funzione caret::train, vedi sotto)

Grid <-  expand.grid(size=c(2));   # in questo caso abbiamo solo il parametro size che nel caso di mlp definisce il numero degli hidden neurons. ma in generale ci possonoe essere piu' named component nelle lista, cioe' un componente per ogni parametro di learning
AUROC <- AUPRC <- conf <- test_set_list <- model <- vector("list", ntimes);

set.seed(1);  # questo assicura che vengano create sempre le stesse partizioni
trainIndex <- caret::createFolds(factor(string_class_matrix[,nrow(string_class_matrix)]), 
                                 k = number.folds, list = TRUE)
y_test <- factor(y_test)
levels(y_test)<-c("negative", "positive")
for (i in 1:ntimes) {
  
  fitControl <- trainControl(method = "cv",
                             number = number.folds,
                             #repeats = 5,
                             ## Estimate class probabilities
                             classProbs = TRUE,
                             ## Evaluate performance using 
                             ## the following function
                             summaryFunction = AUPRCSummary);
  
  
  set.seed(2);
  
  # here the best model is set according to the AUPRC. To set the AUROC change metric = "ROC"
  print(any(is.na(y_test[trainIndex[[i]]])))
  model[[i]] <- caret::train(x=as.data.frame(W[trainIndex[[i]],]), 
                             y=y_test[trainIndex[[i]]],
                             method = algorithm, 
                             trControl = fitControl, 
                             verbose = FALSE, 
                             tuneGrid = Grid,
                             metric = "AUPRC");
  
  
  
  # Probabilistic prediction on the test set
  model.prob <- predict(model[[i]], newdata = as.data.frame(W[-trainIndex[[i]],]), type = "prob");
  
  # true labels
  obs <- y_test[-trainIndex[[i]]];
  
  # computing predicted labels at cutoff=0.5
  pred <- factor(ifelse(model.prob$positive >= .5, "positive", "negative"), levels=c("positive","negative"));
  # construction of the data frame for evaluating the predictions
  test_set_list[[i]] <- data.frame(obs = obs, pred=pred, positive=model.prob$positive, negative=model.prob$negative); 
  
  test_set <- test_set_list[[i]];
  
  # computing AUROC
  AUROC[[i]] <- twoClassSummary(test_set, lev = levels(test_set$obs));  
  # computing AUPRC
  AUPRC[[i]] <- prSummary(test_set, lev = levels(test_set$obs));     
  
  
  # plotting lift: it is possible to make multiple plot with different models
  # trellis.par.set(caretTheme())
  # lift_obj <- lift(obs ~ model.prob$Altered_splicing)
  # ggplot(lift_obj, values = 60);
  
  # plotting calibration
  
  # trellis.par.set(caretTheme())
  # cal_obj <- calibration(obs ~ model.prob$Altered_splicing, cuts = 20)
  # plot(cal_obj, type = "l", auto.key = list(columns = 1,lines = TRUE, points = TRUE));
  # ggplot(cal_obj);
  
  # computiong confusion matrix and different statistics
  conf[[i]] <- best.threshold.confusion(test_set, thresholds = seq(0.01, 0.99, by=0.01));
  
  cat("End of iteration ", i, "\n");
  
} # end of the main for


