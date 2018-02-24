## High-Level Function to train a model by caret pkg for a multi-label classification problem

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
## n: integer number of annotations to be pruned (def. 9). Use this parameter only if "PreProc=TRUE", otherwise set "n=NULL"
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

caret.training <- function(net=W, ann=ann, 
	PreProc=TRUE, n=9, norm=TRUE, kk=10, seed=23, algorithm="mlp", defGrid=data.frame(size=5), cutoff=0.5,
	summaryFunction=AUPRCSummary, metric="AUC", pkg="precrec", scores.dir=scores.dir, perf.dir=perf.dir){

	## load p2p STRING interaction network 
	# net.path <- paste0(net.dir, net.file, ".rda");
	# W <- get(load(net.path));

	## load annotation matrix  
	#ann.path <- paste0(ann.dir, ann.file, ".rda");
	#ann <- get(load(ann.path));

	## shrink number of GO terms. We consider only those GO terms having more than n annotations (n included)
	#if(PreProc){ann <- ann[,colSums(ann)>n];}else{ann <-- ann;}

	## normalize the string matrix dividing each score for the maximum score
	if(norm){W <- W/max(W);}else{W<-W}

	class.num <- ncol(ann);
	for(i in 1:class.num){
		## current GO class execution time
		if(i>1){start.go <- 0;}
		start.go <- proc.time();
		## create stratified folds for k-fold cross-validation in caret::createFolds format-like
		## we use HEMDAG::do.stratified.cv.data.single.class
		y <- ann[,i]; ## annotation vector of the current GO class
		indices <- 1:length(y);
		positives <- which(y==1);
		folds <- do.stratified.cv.data.single.class(indices, positives, kk=kk, seed=seed);
		testIndex <- mapply(c, folds$fold.positives, folds$fold.negatives, SIMPLIFY=FALSE); ## note: index of examples used for test set..
		names(testIndex) <- paste0("Fold", gsub(" ", "0", format(1:kk)));

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

		## setting caret parameter. At the moment NO PARAMETER TUNING
		fitControl <- trainControl(method="none", classProbs=TRUE, returnData=TRUE, 
			sampling=NULL, seeds=seed, summaryFunction=summaryFunction);
		for(k in 1:kk){
			cat("MODEL: ", algorithm, "START", "\n"); 
			start.model <- proc.time();
			model[[k]] <- train(
				x=as.data.frame(W[-testIndex[[k]],]), 
				y=y[-testIndex[[k]]],
				method=algorithm,
				trControl=fitControl,
				tuneGrid=defGrid,
				tuneLength=1,
				metric=metric,
				verbose=FALSE,
				preProcess=NULL,
				scaled=FALSE
			);

			## Probabilistic prediction on the test set
			model.prob <- predict(model[[k]], newdata=as.data.frame(W[testIndex[[k]],]), type="prob");
			
			## true labels
			obs <- y[testIndex[[k]]];

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
			end.model <- proc.time()-start.model;
			cat("FOLD: ", k, "DONE", "****", "ELAPSED TIME: ", end.model["elapsed"], "\n");
		}

		## store scores list as matrix 
		## WRONG WAY: considering both the positive and negative predicted scores..
		## the final matrix will be made-up of just high-scores.. 
		## it sounds like all the predictions are positives
		# scores <- unlist(lapply(seq_along(test_set_list), function(x){
		# 	fold.score <- test_set_list[[x]];
		# 	ind.ann <- which(fold.score$pred=="annotated");
		# 	ind.notann <- which(fold.score$pred=="not_annotated");
		# 	gn.names <- rownames(fold.score);
		# 	fs <- c(fold.score$annotated[ind.ann], fold.score$not_annotated[ind.notann]);
		# 	names(fs) <- c(gn.names[ind.ann], gn.names[ind.notann]);
		# 	fs <- fs[gn.names];
		# 	return(fs);
		# }));
		## RIGHT WAY: considering just the positive predicted scores..
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
		curr.class.name <- colnames(ann)[i]; ## GO class current name
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
		cat("GO class ", i, "(",colnames(ann)[i],")", "****", "DONE", "ELAPSED TIME: ", stop.go["elapsed"], "\n");
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
	save(S, file=paste0(scores.dir, "Scores.", out.name, algorithm, ".", kk, "fcv.rda"), compress=TRUE);
	save(AUC.flat, PRC.flat, file=paste0(perf.dir, "PerfMeas.", out.name, algorithm, ".", kk, "fcv.rda"), compress=TRUE);
}

