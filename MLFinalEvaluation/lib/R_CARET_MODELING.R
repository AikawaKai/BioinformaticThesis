## High-Level Function to train a model by caret pkg for a multi-label classification problem
## Feature Selection with a correlation-based method is also possible, see cfs parameter

### NOTE ###
# **NB0: this function does not allow the tuning of the parameters, but you need to define them at priori. 
# 	You can use those specified in the doc of the library which implements the model
# **NB1: you must load the source code "caret.metrics.R" to use the custom functions "AUPRCSummary"
# 	and "AUROCSummary" (see the "summaryFunction" description below)
# **NB2: the custom functions (see NB1) allow to compute the performance even when the fold does not contain
# 	positive examples (i.e. examples annotated fo a GO class). In this case: AUROC <- 0.5 and AUPR <- 0. 
# 	The default caret functions used to compute performances does not! (NaN or NA returned)

# libaries and source script to call. 
# library(caret); 	## to model by caret..
# library(HEMDAG); 	## to create stratified fold (fun do.stratified.cv.data.single.class)
# source("metrics.R"); ## to use customize performance metrics "AUPRCSummary" and "AUROCSummary" (precrec pkg is required)

## INPUT PARAMETER
## net.dir: relative path to directory where the weighted adjiacency matrix is stored 
## net.file: name of the file containing the weighted adjiacency matrix of the graph (without rda extension)
## ann.dir: relative path where annotation matrix is stored
## ann.file: name of the file containing the the label matrix of the examples (without rda extension)
## PreProc: boolean value. Should the annotation matrix be pruned to those terms having more than n annotations? (def. TRUE)
## sparsify: boolean value. Should the P2P interaction network be sparsified? This means consider only those interactions higher 
##		than a given confidence value (see confidence parameter). All the others interactions are set to zero. (def. FALSE)
## confidence: score below which the interactions are set to zero. use only if sparsify=FALSE. (def. NULL)
## 		NOTA: string suggests to use as confidence interval the following: 
##		1. 400 (medium); 2. 700 (high); ref: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC539959/
## singleton: boolean value, if the P2P network was sparsified, should the singleton node be removed? use only if saprsify=TRUE (def NULL)
## cfs: boolean value:
##		1. TRUE: the features are selected in an unbiased way (i.e. in the training fold of a k-fold cross validation, where k is defined by 
##		the kk parameter) according to the correlation method chosen in the "method" parameter (see below). The selected top-ranked features in 
##		the training fold are then used in the test set.
## 		2. FALSE: none feature selection method is applied, all the features are take into account
## nfeature: number of top ranked feature to be selected (def. 100). If PreProc=FALSE set nfeature=0
## nfeaturePCA: bababaal
## method: correlation method to be used to select the top-ranked nfeature. It can be one of the following: "pearson" (def.), "kendall", "spearman";
##		   NOTE: For kendal coefficient is used the fastest function "cor.fk" of "pcaPP" Rpkg. If cfs=FALSE set method=NULL
## n: integer number (higher than 0) of annotations to be pruned (def. 9). Use this parameter only if PreProc=TRUE, otherwise set n=NULL. 
## norm: boolean value. Should the wadj be normalized? If so, each score is divided for the maximum score. (def. TRUE).
## kk: number of folds of the cross validation (def. 10)
## seed: intialization seed for the random generator to create folds. If "NULL" (def.) no initialization is performed
## algorithm: a string specifying the classification model that "caret::train" function gets in input (def. "mlp").
## 		The list of all the available model can be get by using "getModelInfo() or at "https://topepo.github.io/caret/available-models.html"
## defGrid: a data frame with possible tuning values. The columns are named the same as the tuning parameters. 
## 		To know the default parameters of the method chosen in "algorithm" get a glimpse of the libary's docs or of the 
## 		link: "https://github.com/topepo/caret/tree/master/models/files"
## cutoff: threshold on which choose the predicted label (def. 0.5)
## summaryFunction: evaluate function to compute performance metrics during training phase.
## 		To use the customized performance functions ("precrec" pkg) you must set:
## 			1. "summaryFunction=AUPRCSummary" to compute "AUPRC" (def.); 
## 			2. "summaryFunction=AUROCSummary" to compute "AUROC"; 
## 		To use the predefined performance functions ("caret" pkg) you must set:
## 			1. "summaryFunction=prSummary" to compute "AUPRC"; 
## 			2. "summaryFunction=twoClassSummary" to compute "AUROC"; 
## metric: a string character specifing the metric that will be used to evaluate the performance during training phase.
## 		whether you use "precrec" or "caret" pkg you must set:
## 			1. metric="AUC" to compute "AUPRC" (def); 
## 			2. metric="ROC" to compute "AUROC"; 
## pkg: a string character specified the package to use to compute the performance metric on the test set. 
## 			1. "pkg=precrec" (def.): "AUPRCSummary" and "AUROCSummary" functions are used to compute respectively AUPRC and AUROC.
##				NB: these custom functions allow to compute the performance even when a fold does not contain positive examples. 
##				In this case: AUROC <- 0.5 and AUPR <- 0. 
## 			2. "pkg="caret": "prSummary" and "twoClassSummary" functions are used to compute respectively AUPRC and AUROC.
## 				NB: the prebuilt caret functions are not able to manage folds with zero positive examples. 
## scores.dir: relative path where the flat scores matrix must be stored
## perf.dir: relative path where the performances measures must be stored
## OUTPUT 
## Two rda files stored in the respective output directories:
## 			1. Flat scores matrix: a matrix with examples on rows and classes on columns representing the computed flat scores 
##			for each example and for each considered class, according to the model defined in "algorithm".
##			This file is stored in "scores.dir" directory.
##  		2. "AUPRC" and "AUROC" (average and per class) results computed either with "precrec" or "caret" pkg according 
## 			to the character value defined in "pkg"
caret.modeling.fs.cor.based <- function(net.dir=net.dir, net.file=net.file, ann.dir=ann.dir, ann.file=ann.file, PreProc=TRUE, n=9, 
	norm=TRUE, kk=10, seed=23, sparsify=FALSE, confidence=NULL, singleton=NULL, cfs=TRUE, nfeature=100, nfeaturePCA=seq(1,15,1), 
	method="pearson", algorithm="mlp", defGrid=data.frame(size=5), cutoff=0.5, summaryFunction=AUPRCSummary, metric="AUC", 
	pkg="precrec", scores.dir=scores.dir, perf.dir=perf.dir){
	
	## load P2P STRING interaction network 
	net.path <- paste0(net.dir, net.file, ".rda");
	W <- get(load(net.path));
	if(is.list(W)){
	  W <- W$x
	}
	cat("INTERACTION NETWORK LOADED", "\n");

	## load annotation matrix  
	ann.path <- paste0(ann.dir, ann.file, ".rda");
	ann <- get(load(ann.path));
	cat("ANNOTATION MATRIX LOADED", "\n");

	## sparsify string: consider those interaction higher than a given confidence score. singleton node are also removed
	if(sparsify){
		W[W < confidence] <- 0;
		cat("INTERACTION NETWORK SPARSIFIED", "\n");
		if(singleton){
			W <- W[rowSums(W)!=0, colSums(W)!=0];
			cat("SINGLETON REMOVED", "\n");
		}
	}
	if(sparsify && singleton){ann <- ann[rownames(W),];}

	## normalize the string matrix dividing each score for the maximum score
	if(norm){
		W <- W/max(W);
		cat("INTERACTION NETWORK NORMALIZED", "\n\n");
	}
	
	## shrink number of GO terms. We consider only those GO terms having more than n annotations (n included)
	if(PreProc){ann <- ann[,colSums(ann)>n];}

	## let's start modeling
	class.num <- ncol(ann);
	for(i in 1:class.num){
		## current GO class execution time
		if(i==1){
			cat("CURRENT GO CLASS INDEX: ", i,  "  OUT OF: ", class.num, "\n"); 
		}else{
			cat("\n");
			cat("CURRENT GO CLASS INDEX: ", i,  "  OUT OF: ", class.num, "\n"); 
		}
		curr.class.name <- colnames(ann)[i]; ## GO class current name
		cat("CURRENT GO CLASS NAME: ", curr.class.name,  "\n");

		start.go <- proc.time();
		## create stratified folds for k-fold cross-validation in caret::createFolds format-like
		## we use HEMDAG::do.stratified.cv.data.single.class
		y <- ann[,i]; ## annotation vector of the current GO class
		if(cfs){y.ann <- y;} ## CFS requires a vector, whereas caret-train-model requires a factor

		indices <- 1:length(y);
		positives <- which(y==1);
		folds <- do.stratified.cv.data.single.class(indices, positives, kk=kk, seed=seed);
		testIndex <- mapply(c, folds$fold.positives, folds$fold.negatives, SIMPLIFY=FALSE); ## note: index of examples used for test set..
		names(testIndex) <- paste0("Fold", gsub(" ", "0", format(1:kk)));

		tot.prs <- length(y);
		cat("TOT. PROTEINS: ", tot.prs, "\n"); 
		cat("TOT. POSITIVES: ", length(positives), "\n");

		## lists storing AUROC, AUPRC, the predicted scores on the test set and the model setting
		AUROC <- AUPRC <- test_set_list <- model <- vector(mode="list", length=kk);

		## START MODELLING by CARET ## 
		## caret requires that y is a factor and not a vector of integer number (0/1)
		## TRICK: transform y in a factor and named the outcome as "annotated" (1) and "not_annotated" (0)
		charpos <- "annotated";
		charneg <- "not_annotated";
		y[which(y==1)] <- charpos;
		y[which(y==0)] <- charneg;
		y <- as.factor(y);

		## setting caret parameter. NO PARAMETER TUNING
		fitControl <- trainControl(method="none", classProbs=TRUE, returnData=TRUE,
			sampling=NULL, seeds=seed, summaryFunction=summaryFunction);

		for(k in 1:kk){
			## training set
			if(cfs){
				W.training <- W[-testIndex[[k]],];
				y.cfs <- y.ann[-testIndex[[k]]];
				start.cfs <- proc.time();
				topft <- fs.cor.based(W.training, y.cfs, nfeature=nfeature, method=method);
				stop.cfs <- proc.time() - start.cfs;
				cat("CFS TIME ELAPSED IN TRAINING FOLD ", k, ":", stop.cfs["elapsed"], "\n");
				W.training <- W[-testIndex[[k]], topft];
			}else if(ncol(W)!=nfeature){
				W.training <- W[-testIndex[[k]], nfeaturePCA];
			}else{
				W.training <- W[-testIndex[[k]], ];
			}
			cat("TOT. PROTEINS/FEATURE IN TRAINING FOLD: ", k, ": ", dim(W.training), "\n");
			
			## start modeling
			fold.start.model <- proc.time();
			model[[k]] <- train(
				x=as.data.frame(W.training),
				y=y[-testIndex[[k]]],
				method=algorithm,
				trControl=fitControl,
				tuneGrid=defGrid,
				tuneLength=1,
				metric=metric
			);

			## test model on the top-ranked features, if cfs=TRUE
			if(cfs){
				W.test <- W[testIndex[[k]], topft];
			}else if(ncol(W)!=nfeature){
				W.test <- W[testIndex[[k]], nfeaturePCA];
			}else{
				W.test <- W[testIndex[[k]], ];
			}

			## test model
			model.prob <- predict(model[[k]], newdata=as.data.frame(W.test), type="prob");
			
			## true labels
			obs <- y[testIndex[[k]]];
			cat("TOT. PROTEINS/FEATURE IN TEST FOLD", k, ": ", dim(W.test), "\n");
			
			## Probabilistic prediction on the test set
			## computing predicted labels at a given cutoff
			pred <- factor(ifelse(model.prob[[charpos]] >= cutoff, charpos, charneg), levels=levels(y));
			
			## construction of the data frame for evaluating the predictions
			test_set_list[[k]] <- data.frame(obs, pred, model.prob[[charpos]], model.prob[[charneg]]); 
			names(test_set_list[[k]]) <- c("obs","pred",charpos, charneg);
			test_set <- test_set_list[[k]];

			## computing AUROC
			if(pkg=="precrec"){
				AUPRC[[k]] <- AUPRCSummary(test_set, lev=levels(test_set$obs), model=algorithm); ## custom 
				AUROC[[k]] <- AUROCSummary(test_set, lev=levels(test_set$obs), model=algorithm); ## custom
				cat("AUPRC and AUROC measures DONE", "\n");
			}else{
				AUPRC[[k]] <- prSummary(test_set, lev=levels(test_set$obs), model=algorithm);	## caret
				AUROC[[k]] <- twoClassSummary(test_set, lev=levels(test_set$obs), model=algorithm); ## caret
				cat("AUPRC and AUROC measures DONE", "\n");
			}
			## fold execution time and status
			fold.end.model <- proc.time() - fold.start.model;
			if(k<kk){
				cat("FOLD:", k, "DONE", " **** ELAPSED TIME: ", fold.end.model["elapsed"], "\n\n");
			}else{
				cat("FOLD:", k, "DONE", " **** ELAPSED TIME: ", fold.end.model["elapsed"], "\n");
			}	
		}

		## store scores list as matrix consieering just the positive predicted scores..
		## the final matrix will be made-up both of high and low scores.. 
		## high-score positive prediction, low score negative prediction..
		scores <- unlist(lapply(seq_along(test_set_list), function(x){
			test_score <- test_set_list[[x]];
			pos_score <- test_score$annotated;
			names(pos_score) <- rownames(test_score);
			return(pos_score);
		}));

		## create an empty vector to store the scores of the current class. 
		## the others will be added by column
		if(i==1){S <- c()};
		S <- cbind(S,scores[names(y)]); ## rownames of S in the same order of y 
		colnames(S)[i] <- curr.class.name;

		## merge caret::twoClassSummary results 
		roc.fold.av <- Reduce("+", AUROC)/kk;
		if(i==1){AUC.class <- c()};
		AUC.class <- append(AUC.class, roc.fold.av[["ROC"]]);
		names(AUC.class)[i] <- curr.class.name;
		
		## merge caret::prSummary results 
		prc.fold.av <- Reduce("+", AUPRC)/kk;
		if(i==1){PRC.class <- c()};
		PRC.class <- append(PRC.class, prc.fold.av[["AUC"]]);
		names(PRC.class)[i] <- curr.class.name;

		stop.go <- proc.time() - start.go;
		timing <- stop.go["elapsed"];
		timing.m <-  round(timing/(60),4);
		timing.h <- round(timing/(3600),4);
		cat("***GO CLASS ", curr.class.name, paste0("(",i,")"), " ELAPSED TIME: ", timing, "sec", 
			paste0("(",timing.m, " minutes ** ", timing.h, " hours)"), "\n");
	}
	## store AUROC results average and per class (NOTE: per class are in turn averaged by k-fold)
	AUC.av <- mean(AUC.class);
	AUC.flat <- list(average=AUC.av, per.class=AUC.class);
	## store AURPC results average and per class
	PRC.av <- mean(PRC.class);
	PRC.flat <- list(average=PRC.av, per.class=PRC.class);
	
	## save the results
	fn <- strsplit(ann.file,"_");
	out.name <- paste0(fn[[1]][1:4], ".", collapse="");
	if(cfs){
		save(S, file=paste0(scores.dir, "Scores.", out.name, method, ".", nfeature, ".feature.", algorithm, ".", kk, "fcv.rda"), compress=TRUE);
		save(AUC.flat, PRC.flat, file=paste0(perf.dir, "PerfMeas.", out.name, method, ".", nfeature, ".feature.", algorithm, ".", kk, "fcv.rda"), compress=TRUE);
	}else if(ncol(W)!=nfeature){
		save(S, file=paste0(scores.dir, "Scores.", out.name, method, ".", nfeaturePCA, ".PCAfeature.", algorithm, ".", kk, "fcv.rda"), compress=TRUE);
		save(AUC.flat, PRC.flat, file=paste0(perf.dir, "PerfMeas.", out.name, method, ".", nfeaturePCA, ".PCAfeature.", algorithm, ".", kk, "fcv.rda"), 
			compress=TRUE);
	}else{
		save(S, file=paste0(scores.dir, "Scores.", out.name, out.name, algorithm, ".", kk, "fcv.rda"), compress=TRUE);
		save(AUC.flat, PRC.flat, file=paste0(perf.dir, "PerfMeas.", out.name, algorithm, ".", kk, "fcv.rda"), compress=TRUE);
	}
}

## Function to select the top ranked features by a correlation method 
## Arguments:
## m: a numeric matrix with examples in rows and feaures in columns
## y: numeric vector of the labels: 1 stands for positive, 0 for negative
## nfeature : number of top ranked features to be selected
## method : correlation method to be used: one of the following: "pearson", "kendall", "spearman" (def. pearson)
## Value
## A vector of length n.features, with the indices of the selected top-ranked n.features. The indices correspond to the columns of m.
## NOTE: for large dataset (features > 1000) pearson is the fastest meethod.
## NOTE: for kendal we use the fastest algorithm "cor.fk" from pkg "pcaPP" (https://www.rdocumentation.org/packages/pcaPP/versions/1.9-60/topics/cor.fk)
fs.cor.based <- function(m, y, nfeature=100, method="pearson"){
	## suppress warings (the standard deviation is zero) due to cross-validation. NA vals are returned.
	suppressWarnings(
		res <- cor(y, m, method=method)[1,]
	);
	if(method=="kendal"){
		res <- apply(m, 1, function(x) cor.fk(y, x)); ## use fast kendal algorithm
	}
	## select the indices of the first n.feature top ranked features
	## put last the NA vals (if any).  
	ind.selected <- order(abs(res), decreasing=TRUE, na.last=TRUE)[1:nfeature];
	return(ind.selected);
}


