getCurrentAlgoGrid <- function(algo, nfeature){
  if(algo == "gaussprPoly"){
    return(data.frame(degree = 1, scale = 1))
  }
  if(algo == "mlp"){
    return(data.frame(size = 5))
  }
  if(algo == "knn"){
    return(data.frame(k=9))
  }
  if(algo == "svmLinear"){
    return(data.frame(C = 1))
  }
  if(algo == "svmRadial"){
    return(data.frame(C = 1, sigma = 1))
  }
  if(algo == "xgbLinear"){
    return(data.frame(nrounds = 15 , lambda = 1, alpha = 0, eta = 0.3))
  }
  if(algo == "rf"){
    return(data.frame(mtry = sqrt(nfeature)))
  }
  if(algo == "C5.0"){
    return(data.frame(trials = 1, model = "tree" , winnow =FALSE ))
  }
  if(algo == "LogitBoost"){
    return(data.frame(nIter = nfeature))
  }
  if(algo == "glmnet"){
    return(data.frame(alpha = 1, lambda = 100))
  }
  if(algo == "randomGLM"){
    return(data.frame(maxInteractionOrder = 1))
  }
  if(algo == "treebag"){
    return(data.frame(parameter = "none"))
  }
  if(algo == "AdaBoost.M1"){
    return(data.frame(mfinal = 100 , maxdepth = 30 , coeflearn = "Breiman"))
  }
  if(algorithm == "ranger"){
    return(data.frame(mtry=trunc(sqrt(nfeature)), splitrule="gini", min.node.size=1))
  }
  if(algorithm == "kknn"){
    return(data.frame(kmax=19, distance=2, kernel="optimal"))
  }
  if(algorithm == "naive_bayes"){
    return(data.frame(laplace=0, usekernel=FALSE, adjust=1))
  }
  if(algorithm == "adaboost"){
    return(data.frame(nIter=trunc(sqrt(nfeature)), method="Adaboost.M1"))
  }
  if(algorithm == "svmLinear2"){
    return(data.frame(cost=1))
  }
}

getAnnotationFileName<-function(curr_onto){
  if(curr_onto=="BP"){
    return("6239_CAEEL_GO_BP_ANN_STRING_v10.5_20DEC17")
  }
  if(curr_onto=="MF"){
    return("6239_CAEEL_GO_MF_ANN_STRING_v10.5_20DEC17")
  }
  if(curr_onto=="CC"){
    return("6239_CAEEL_GO_CC_ANN_STRING_v10.5_20DEC17")
  }
  stop("TYPED WRONG ONTOLOGY: USE 'BP' 'MF' 'CC' ")
}
