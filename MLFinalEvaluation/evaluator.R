library(caret);	
library(HEMDAG);
SERVER <- FALSE


if(SERVER){
  path <- "/home/modore/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/MLFinalEvaluation/"
  data.fs.path <- "/data/GO_EXP/6239_CAEEL/"
  data.pca.path <- "/home/modore/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/MLFinalEvaluation/data/"
  
}else{
  path <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/MLFinalEvaluation/"
  data.fs.path <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/6239_CAEEL/"
  data.pca.path <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/MLFinalEvaluation/data/"
}

source(paste0(path,"/lib/R_CARET_MODELING.R"))
source(paste0(path, "/lib/metrics.R"))
source(paste0(path, "/lib/utility.R"))
args <- commandArgs(trailingOnly = TRUE)
algorithm <- args[1]
curr_onto <- args[2]
type <- args[3]

ann.dir <- data.fs.path
ann.file <- getAnnotationFileName(curr_onto)

if(type=="FS"){
  net.dir <- data.fs.path
  net.file <- "6239_CAEEL_STRING_NET_v10.5"
  nfeature <- 100
  cfs <- TRUE
}else if(type=="PCA"){
  net.dir <- data.pca.path
  net.file <- "pca"
  nfeature <- 15
  cfs <- FALSE
  nfeaturePCA <- seq(1,15,1)
}else{
  stop("WRONG INPUT \nIf Feature Selection is needed type: FS \nIf pca is needed type: PCA")
}


caret.modeling.fs.cor.based(net.dir=net.dir, net.file=net.file, ann.dir=ann.dir, 
                            ann.file=ann.file, PreProc=TRUE, n=9, norm=TRUE, kk=10, 
                            seed=23, sparsify=FALSE, confidence=NULL, singleton=NULL, 
                            cfs=cfs, nfeature=nfeature, nfeaturePCA=nfeaturePCA, 
                            method="pearson", algorithm=algorithm, 
                            defGrid=data.frame(size=5), cutoff=0.5, 
                            summaryFunction=AUPRCSummary, metric="AUC", 
                            pkg="precrec", scores.dir=scores.dir, perf.dir=perf.dir)
