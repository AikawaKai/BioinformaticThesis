executeALGO <- function(path_scores, file_, path_dag, dag.file, path_ann, ann.file, rec.levels,
                        hierPerfPath, hierScoresPath, hierAlgo){
  
  if(hierAlgo=="GPAV"){
    Do.GPAV(flat.dir = path_scores, flat.file = file_,  dag.dir = path_dag, dag.file = dag.file, 
            ann.dir = path_ann, hierScore.dir = hierScoresPath, ann.file = ann.file,  
            perf.dir = hierPerfPath, rec.levels = rec.levels, parallel = TRUE,  norm.type = "MaxNorm", 
            n.round = 3, W = NULL, f.criterion = "F", ncores = 5, norm = FALSE, folds = NULL)
  }
  if(hierAlgo=="HTD"){
    Do.HTD(flat.dir = path_scores, flat.file = file_,  dag.dir = path_dag, dag.file = dag.file, 
           ann.dir = path_ann, hierScore.dir = hierScoresPath, ann.file = ann.file,  
           perf.dir = hierPerfPath, rec.levels = rec.levels, norm.type = "MaxNorm", n.round = 3,
           f.criterion = "F", norm = FALSE, folds = NULL)
  }
  
}

calculateHIER <- function(files, dag, path_, path_scores, path_dag, path_ann, hierAlgo){
  files <- files[lapply(files, function(x){grepl(dag, x)})==TRUE]
  dag.file = paste0("/6239_CAEEL_GO_", dag, "_DAG_STRING_v10.5_20DEC17")
  ann.file =  paste0("/6239_CAEEL_GO_", dag, "_ANN_STRING_v10.5_20DEC17")
  rec.levels <- seq(from=0.1, to=1, by=0.1);
  for(file_ in files){
    file_ <- substring(file_, 1, nchar(file_)-4)
    hierScoresPath <- paste0(path_, "/hierScores/", hierAlgo, "/")
    hierPerfPath <- paste0(path_, "/hierPerf/", hierAlgo, "/")
    executeALGO(path_scores, file_, path_dag, dag.file, path_ann, ann.file, rec.levels, hierPerfPath,
                hierScoresPath, hierAlgo)
  }
  
}

library(HEMDAG)

SERVER <- FALSE
args <- commandArgs(trailingOnly = TRUE)
hierAlgo <- args[1]

if(SERVER){
  path_ <- "/home/modore/Tesi-Bioinformatica/BioinformaticThesis/Ensemble/"
}else{
  path_ <- "/home/kai/Documenti/UNIMI/BioinformaticThesis/Ensemble/"
}

# DAG path
path_dag <- paste0(path_, "DAG/")
path_ann <- paste0(path_, "ANN/")

dags <- c("BP", "MF", "CC")
feat_select <- c("PCA", "FS")
for(dag in dags){
  for(fs in feat_select){
    path_scores <- paste0(path_, "scores/", fs, "/")
    files <- list.files(path = path_scores, recursive = TRUE)
    calculateHIER(files, dag, path_, path_scores, path_dag, path_ann, hierAlgo)
  }
}




