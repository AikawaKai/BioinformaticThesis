library(caret); 	## to model
library(HEMDAG); 	## to create stratified fold (do.stratified.cv.data.single.class)

#LIBS
lib.dir <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/MLFeatureSelection/lib/"
source(paste(lib.dir, "caret.metrics.R", sep =""));  ## to use customize performance metrics ("precrec" pkg)
source(paste(lib.dir, "R_CARET_MODELLING.R", sep = "")); ## to call the high-level fun caret.training

## PARAMETERS SETTING
annotation.dir <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/";
net.dir <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/MLFeatureSelection/data/"; ## set your data dir..
net.file <- "pca.rda";
ann.file <- "/6239_CAEEL/6239_CAEEL_GO_MF_ANN_STRING_v10.5_20DEC17.rda";
PreProc <- TRUE;
norm <- TRUE;
n <- 9;
kk <- 10;
algorithm <- "mlp";
defGrid	<- data.frame(size=5);
cutoff <- 0.5;
summaryFunction <- AUPRCSummary;
metric <- "AUC"; 
pkg <- "precrec";
scores.dir <- perf.dir <- "./"; ## set the desidered output dir
seed <- 1;

# LOADING DATA
load(file=paste(annotation.dir, ann.file, sep=""));
load(file=paste(net.dir, net.file, sep=""));

W <- pca$x

W <- W[,1:1000]

# selected classes for replicability
set.seed(seed)
ann_select <-ann[,colSums(ann)>9]
ann_sample <- sample(colnames(ann_select), 10)
print(ann_sample)
classes <- ann_select[,ann_sample]



## MODELLING by CARET
caret.training(
	net=W, ann=classes, PreProc=PreProc, 
	n=n, norm=norm, kk=kk, seed=seed, algorithm=algorithm, summaryFunction=summaryFunction,
	defGrid=defGrid, cutoff=cutoff, metric=metric, pkg=pkg, scores.dir=scores.dir, perf.dir=perf.dir
)


