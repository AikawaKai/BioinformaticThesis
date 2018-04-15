library(caret);	
library(HEMDAG);
SERVER <- TRUE
TEST <- FALSE
ESTIMATE <- TRUE

algorithms <- list("lda", "C5.0", "mlp")
ontos <- list("BP", "MF", "CC")
type <- "FS"

if(ESTIMATE){
  scores_path <- "scores_estimate/"
  perf_path <-"perf_estimate/"
  csv_path <- "csv_estimate/"
}else{
  scores_path <- "scores/"
  perf_path <-"perf/"
  csv_path <- "csv/"
}

if(SERVER){
  path <- "/home/modore/Tesi-Bioinformatica/BioinformaticThesis/MLFinalEvaluation/"
  data.fs.path <- "/home/notaro/GO_EXP/6239_CAEEL/DATA/"
  data.pca.path <- "/home/modore/Tesi-Bioinformatica/BioinformaticThesis/MLFinalEvaluation/data/"
  scores.dir <- paste0(path, scores_path)
  perf.dir <- paste0(path, perf_path)
}else{
  path <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/MLFinalEvaluation/"
  data.fs.path <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/6239_CAEEL/"
  data.pca.path <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/MLFinalEvaluation/data/"
  scores.dir <- paste0(path, scores_path)
  perf.dir <- paste0(path, perf_path)
}

source(paste0(path,"/lib/R_CARET_MODELING.R"))
source(paste0(path, "/lib/metrics.R"))
source(paste0(path, "/lib/utility.R"))
# args <- commandArgs(trailingOnly = TRUE)
# algorithm <- args[1]
# curr_onto <- args[2]
# type <- args[3]

for(algorithm in algorithms){
  for(curr_onto in ontos){
    ann.dir <- data.fs.path
    ann.file <- getAnnotationFileName(curr_onto)
    curr_csv_name <- paste0(type, "_", curr_onto, "_", algorithm, ".csv")
    curr_csv_name <- paste0(path, csv_path, curr_csv_name)
    
    if(type=="FS"){
      net.dir <- data.fs.path
      net.file <- "6239_CAEEL_STRING_NET_v10.5"
      nfeature <- 100
      cfs <- TRUE
      defGrid <- getCurrentAlgoGrid(algorithm, nfeature)
    }else if(type=="PCA"){
      net.dir <- data.pca.path
      net.file <- "pca"
      nfeature <- 15
      cfs <- FALSE
      nfeaturePCA <- seq(1,15,1)
      defGrid <- getCurrentAlgoGrid(algorithm, nfeature)
    }else{
      stop("WRONG INPUT \nIf Feature Selection is needed type: FS \nIf pca is needed type: PCA")
    }
    
    
    caret.modeling.fs.cor.based(net.dir=net.dir, net.file=net.file, ann.dir=ann.dir, 
                                ann.file=ann.file, PreProc=TRUE, n=9, norm=TRUE, kk=10, 
                                seed=23, sparsify=FALSE, confidence=NULL, singleton=NULL, 
                                cfs=cfs, nfeature=nfeature, nfeaturePCA=nfeaturePCA, 
                                method="pearson", algorithm=algorithm, 
                                defGrid=defGrid, cutoff=0.5, 
                                summaryFunction=AUPRCSummary, metric="AUC", 
                                pkg="precrec", scores.dir=scores.dir, perf.dir=perf.dir,
                                csv_name=curr_csv_name, TEST=TEST, estimate=ESTIMATE)
    
  }
}

