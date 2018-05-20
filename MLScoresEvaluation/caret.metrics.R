# January 2018
# Functions to compute the one-shot and averaged across folds AUROC and AUPRC

library(precrec);

# function to compute the AUROC one-shot and averaging across folds
# Input:
# labels : a vector or factor with the labels (values in 0,1)
# pred : a vector of the predictions (same dimension as labels)
# folds : vector with number of the fold (same dimension as labels). If NULL no predefined folds are given and only one-shot AUROC is computed
# digits : number of rounding digits
# It returns a numeric vector with three elements:
# - the one-shot AUROC
# - the AUROC averaged across folds
# - the stdev of the AUROC averaged acorss folds.
compute.AUROC <- function (labels, pred, folds=NULL, digits=4) {
	y <- ifelse(labels==1, 1, 0);
	if (!is.null(folds)){ # compute AUROC averaged across folds
		k <- max(folds);
		AUROC <- numeric(k+1);
		for(j in 0:k){
			test.indices <- which(folds==j);
			if (sum(y[test.indices]) > 0){ # if there is at least 1 positive in the jth fold
				sscurves <- evalmod(scores = pred[test.indices], labels = y[test.indices]);
				m<-attr(sscurves,"auc",exact=FALSE);
				AUROC[j+1] <- round(m[1,"aucs"],digits);
			}else{
				AUROC[j+1] <- 0.5;
			}
		}
	}
	## to handle the case in which a fold does not contain positive examples
	if(sum(y)==0){
		AUROC.oneshot <- 0.5;
	}else{
		sscurves <- evalmod(scores=pred, labels=y);
		m <- attr(sscurves,"auc",exact=FALSE);
		AUROC.oneshot <- round(m[1,"aucs"],digits);
	}
	if(!is.null(folds)){
		res <- c(AUROC.oneshot, round(mean(AUROC), digits), round(sd(AUROC),digits));
	}else{
		res <- c(AUROC.oneshot, 0, 0);
		names(res) <- c("one.shot.AUROC","av.AUROC", "stdev");
	}
	return(res); 
}

# function to compute the AUPRC one-shot and averaging across folds
# Input:
# labels : a vector or factor with the labels (values in 0,1)
# pred : a vector of the predictions (same dimension as labels)
# folds : vector with number of the fold (same dimension as labels). If NULL no predefined folds are given and only one-shot AUROC is computed
# digits : number of rounding digits
# It returns a numeric vector with three elements:
# - the one-shot AUPRC
# - the AUPRC averaged across folds
# - the stdev of the AUPRC averaged acorss folds.
compute.AUPRC <- function (labels, pred, folds=NULL, digits=4) {
	y <- ifelse(labels==1, 1, 0);
	if (!is.null(folds)){ # compute AUROC averaged across folds
		k <- max(folds);
		AUPRC <- numeric(k+1);
		for(j in 0:k){
			test.indices <- which(folds==j);
			if (sum(y[test.indices]) > 0) { # in there is at least 1 positive in the jth fold
				sscurves <- evalmod(scores = pred[test.indices], labels = y[test.indices]);
				m<-attr(sscurves,"auc",exact=FALSE);
				AUPRC[j+1] <- round(m[2,"aucs"],digits);
			}else{
				AUPRC[j+1] <- 0;
			}
		}
	}
	## to handle the case in which a fold does not contain positive examples
	if(sum(y)==0){
		AUPRC.oneshot <- 0;
	}else{
		sscurves <- evalmod(scores=pred, labels=y);
		m <- attr(sscurves, "auc", exact=FALSE);
		AUPRC.oneshot <- round(m[2,"aucs"], digits);
	}
	if(!is.null(folds)) {
		res <- c(AUPRC.oneshot, round(mean(AUPRC), digits), round(sd(AUPRC),digits));
	}else{
		res <- c(AUPRC.oneshot, 0, 0);
		names(res) <- c("one.shot.AUPRC","av.AUPRC", "stdev");
	}
	return(res); 
}

########################################################################
# function to be used by the caret package for AUPRC metric
AUPRCSummary <- function(data, lev=NULL, model=NULL){
	labels <- ifelse(data$obs == lev[1], 1, 0);
	pred <- as.numeric(data[,lev[1]]);
	out <- compute.AUPRC(labels, pred=pred, folds=NULL, digits=6)[1]; 
	names(out) <- "AUC"; ## named the same as caret::prSummary
	return(out);
}

# function to be used by the caret package for AUROC metric
AUROCSummary <- function(data, lev=NULL, model=NULL){
	labels <- ifelse(data$obs == lev[1], 1, 0);
	pred <- as.numeric(data[,lev[1]]);
	out <- compute.AUROC(labels, pred=pred, folds=NULL, digits=6)[1]; 
	names(out) <- "ROC"; ## named the same as caret::twoClassSummary
	return(out);
}

