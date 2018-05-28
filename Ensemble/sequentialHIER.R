calculateHIER <- function(files, dag, path_, path_scores, path_dag, path_ann){
  files <- files[lapply(files, function(x){grepl(dag, x)})==TRUE]
  dag.file = paste0("/6239_CAEEL_GO_", dag, "_DAG_STRING_v10.5_20DEC17")
  ann.file =  paste0("/6239_CAEEL_GO_", dag, "_ANN_STRING_v10.5_20DEC17")
  rec.levels <- seq(from=0.1, to=1, by=0.1);
  for(file_ in files){
    file_ <- substring(file_, 1, nchar(file_)-4)
    print(file_)
    print(path_dag)
    print(path_ann)
    print(paste0(path_scores, file_))
    hierScoresPath <- paste0(path_, "/hierScores/")
    hierPerfPath <- paste0(path_, "/hierPerf/")
    Do.GPAV(flat.dir = path_scores, flat.file = file_, 
            dag.dir = path_dag, dag.file = dag.file, 
            ann.dir = path_ann, hierScore.dir = hierScoresPath,
            ann.file = ann.file, perf.dir = hierPerfPath,
            rec.levels = rec.levels, parallel = TRUE, 
            norm.type = "MaxNorm", n.round = 3, W = NULL,
            f.criterion = "F", ncores = 5, norm = FALSE,
            folds = 5)
  }
  
}

library(HEMDAG)

SERVER <- FALSE
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
calculateHIER(files, dag, path_, path_scores, path_dag, path_ann)

