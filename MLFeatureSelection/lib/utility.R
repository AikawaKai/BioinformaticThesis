library(stats)
library(Rcpp)

ptestCalculation <- function(col_vals, col_classes){
  curr_data <- data.frame(vals = col_vals, classes = as.factor(col_classes))
  p_value <- t.test(vals ~ classes, data=curr_data)[["p.value"]]
  cat(p_value)
  return(c(p_value))
}
sourceCpp(file=paste("/home/kai/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/MLFeatureSelection/", "fastIter.cpp", sep=""))

iterTtestCalculation <-function(W, ann){
  for(i in 1:ncol(ann)){
    for(j in 1:ncol(W)){
      ptestCalculation(W[,j], ann[,i])
    }
  }
}