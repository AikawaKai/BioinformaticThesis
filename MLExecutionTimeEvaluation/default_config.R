# gaussprPoly
algorithm <- "gaussprPoly";
defGrid <- data.frame(degree=1, scale=1);
# doclink: https://cran.r-project.org/web/packages/kernlab/kernlab.pdf (pag 9)
# note: -

# xgbLinear
algorithm <- "xgbLinear";
defGrid <- data.frame(nrounds=15, lambda=1, alpha=0, eta=0.3);
# doclink: https://cran.r-project.org/web/packages/xgboost/xgboost.pdf (pag 38)
# note: Lower value for eta implies larger value for nrounds: low eta value means model more robust to overfitting but slower to compute. Default: 0.3

# AdaBoost.M1
algorithm <- "AdaBoost.M1"; 
data.frame(mfinal=100, maxdepth=30, coeflearn="Breiman");
# doclink: https://cran.r-project.org/web/packages/adabag/adabag.pdf (pag 9)
# doclink: (maxdepth param) https://cran.r-project.org/web/packages/rpart/rpart.pdf (pag 22)
# note: -

# svmRadial
algorithm <- "svmRadial";
defGrid <- data.frame(C=1, sigma=1);
# doclink: https://cran.r-project.org/web/packages/kernlab/kernlab.pdf (pag 56) 
# doclink: https://cran.r-project.org/web/packages/kernlab/kernlab.pdf#Rfn.rbfdot (for sigma param, pag 9)
# note: -

# random forest
algorithm <- "rf";
defGrid <- data.frame(mtry=sqrt(p)); 
# doclink: https://cran.r-project.org/web/packages/randomForest/randomForest.pdf (pag 18)
# note: p is the number of predictors, e.g. in 6239_CAEEL p = 15752, so mtry = 126

# LogitBoost
algorithm <- "LogitBoost";
defGrid <- data.frame(nIter=ncol(x)); 
# doclink: https://cran.r-project.org/web/packages/caTools/caTools.pdf (pag 10)
# note: in 6239_CAEEL ncol(x) = 15752

# C5.0
algorithm <- "C5.0";
defGrid <- data.frame(trials=1, model="tree", winnow=FALSE);
# doclink: https://cran.r-project.org/web/packages/C50/C50.pdf (pag 2)
# note: -

# treebag
algorithm <- "treebag";
defGrid <- data.frame(parameter="none");
# NOTE: no tuning parameter.. 

# randomGLM
algorithm <- "randomGLM";
defGrid <- data.frame(maxInteractionOrder=1);
# doclink: https://cran.r-project.org/web/packages/randomGLM/randomGLM.pdf
# NOTE: Warning: higher order interactions greatly increase the computation time. We see no benefit of using maxInteractionOrder>2.

# mlp
algorithm <- "mlp";
defGrid <- data.frame(size=5);
# doclink: https://cran.r-project.org/web/packages/RSNNS/RSNNS.pdf

# knn
algorithm <- "knn";
defGrid <- data.frame(k=9);
# NOTE: def k=1 (doclink: https://stat.ethz.ch/R-manual/R-devel/library/class/html/knn.html);

# svmLinear
algorithm <- "svmLinear";
defGrid <- data.frame(C=1);
# doclink: https://cran.r-project.org/web/packages/kernlab/kernlab.pdf

# glmnet
algorithm <- "glmnet";
defGrid <- data.frame(alpha=1, lambda=100);
# doclink: https://cran.r-project.org/web/packages/glmnet/glmnet.pdf
# NOTE: A user supplied lambda sequence. Typical usage is to have the program compute its own lambda sequence based on nlambda and
# 		lambda.min.ratio. Supplying a value of lambda overrides this. WARNING: use with care. Do not supply a single value for lambda (for
# 		predictions after CV use predict() instead). Supply instead a decreasing sequence of lambda values. glmnet relies on its warms starts for
# 		speed, and its often faster to fit a whole path than compute a single fit.
# NB: in our case, since we do not wanna do tuning parameters, we cannot set lambda with a own decreasing sequence. If we do that
# the following error is returned: "Error: Only one model should be specified in tuneGrid with no resampling"... so I set lambda=100. 
# this choice is widely debatable..

