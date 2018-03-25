library(caret);	
library(HEMDAG);

SERVER <- FALSE
args <- commandArgs(trailingOnly = TRUE)
algorithm <- args[1]
curr_onto <- args[2]
type <- args[3]
if(type=="FS"){
  nfeature = 100
}else if(type=="PCA"){
  nfeature = 15
}else{
  stop("WRONG INPUT \nIf Feature Selection is needed type: FS \nIf pca is needed type: PCA")
}

if(SERVER){
  path <- "/home/modore/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/MLFinalEvaluation/"
}else{
  path <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/MLFinalEvaluation/"
}

source(paste0(path,"lib/R_CARET_MODELING.R"))
source(paste0(path, "/lib/metrics.R"))
