library(caret)

models <- c("svmLinear", "svmRadial", "mlp", "mlpML", 
            "AdaBoost.M1", "rf", "C5.0", "xgbLinear",
            "lda", "LogitBoost", "gaussprPoly", "glmnet",
            "randomGLM", "treebag", "knn")

for(i in seq(1:length(models))){
  print("###########")
  print(models[[i]])
  for(j in seq(1:length(getModelInfo(models[[i]]))))
  {
    print(getModelInfo(models[[i]])[[j]]$grid)  
  }
}
out <- data.frame(tau = 2^runif(15752, min = -5, max = 10))
out
