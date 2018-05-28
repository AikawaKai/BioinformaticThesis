executeGPAV <- function(path_scores, file_, path_dag, dag.file, path_ann, ann.file, rec.levels,
                        hierPerfPath, hierScoresPath, algo){
  algo(flat.dir = path_scores, flat.file = file_,  dag.dir = path_dag, dag.file = dag.file, 
       ann.dir = path_ann, hierScore.dir = hierScoresPath, ann.file = ann.file,  perf.dir = hierPerfPath, 
       rec.levels = rec.levels, parallel = TRUE,  norm.type = "MaxNorm", n.round = 3, W = NULL, 
       f.criterion = "F", ncores = 5, norm = FALSE, folds = NULL)
}

selectFunct <- function(hierAlgo){
  if(hierAlgo=="GPAV"){
    algo <- Do.GPAV
  }
  return(algo)
}

calculateHIER <- function(files, dag, path_, path_scores, path_dag, path_ann, hierAlgo){
  files <- files[lapply(files, function(x){grepl(dag, x)})==TRUE]
  dag.file = paste0("/6239_CAEEL_GO_", dag, "_DAG_STRING_v10.5_20DEC17")
  ann.file =  paste0("/6239_CAEEL_GO_", dag, "_ANN_STRING_v10.5_20DEC17")
  rec.levels <- seq(from=0.1, to=1, by=0.1);
  algo <- selectFunct(hierAlgo)
  for(file_ in files){
    file_ <- substring(file_, 1, nchar(file_)-4)
    hierScoresPath <- paste0(path_, "/hierScores/", hierAlgo, "/")
    hierPerfPath <- paste0(path_, "/hierPerf/", hierAlgo, "/")
    executeGPAV(path_scores, file_, path_dag, dag.file, path_ann, ann.file, rec.levels, hierPerfPath,
                hierScoresPath, algo)
  }
  
}

library(HEMDAG)

SERVER <- FALSE
hierAlgo <- "GPAV"
dag <- "CC"
fs <- "PCA/" 

if(SERVER){
  path_ <- ""
}else{
  path_ <- "/home/kai/Documenti/UNIMI/BioinformaticThesis/Ensemble/"
}

# DAG path
path_dag <- paste0(path_, "DAG/")
path_ann <- paste0(path_, "ANN/")


path_scores <- paste0(path_, "scores/", fs)
files <- list.files(path = path_scores, recursive = TRUE)


calculateHIER(files, dag, path_, path_scores, path_dag, path_ann, hierAlgo)



