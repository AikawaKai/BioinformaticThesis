library(caret); 	## to model
library(HEMDAG); 	## to create stratified fold (do.stratified.cv.data.single.class)
source("/home/kai/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/MLScoresEvaluation/caret.metrics.R");  ## to use customize performance metrics ("precrec" pkg)
source("/home/kai/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/MLScoresEvaluation/R_CARET_MODELLING.R"); ## to call the high-level fun caret.training

## parameters setting
net.dir <- ann.dir <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/6239_CAEEL/"; ## set your data dir..
net.file <- "6239_CAEEL_STRING_NET_v10.5";
ann.file <- "6239_CAEEL_GO_BP_ANN_STRING_v10.5_20DEC17";
PreProc <- TRUE;
norm <- TRUE;
n <- 9;
kk <- 10;
seed <- 23;
algorithm <- "mlp";
defGrid	<- data.frame(size=5);
cutoff <- 0.5;
summaryFunction <- AUPRCSummary;
metric <- "AUC"; 
pkg <- "precrec";
scores.dir <- perf.dir <- "./"; ## set the desidered output dir

## MODELLING by CARET
caret.training(
	net.dir=net.dir, net.file=net.file, ann.dir=ann.dir, ann.file=ann.file, PreProc=PreProc, 
	n=n, norm=norm, kk=kk, seed=seed, algorithm=algorithm, summaryFunction=summaryFunction,
	defGrid=defGrid, cutoff=cutoff, metric=metric, pkg=pkg, scores.dir=scores.dir, perf.dir=perf.dir
)


