calculateHIER <- function(files, dag, path_scores, path_dag, path_ann){
  files <- files[lapply(files, function(x){grepl(dag, x)})==TRUE]
  for(file_ in files){
    file_ <- substring(file_, 1, nchar(file_)-4)
    print(file_)
    print(path_dag)
    print(path_ann)
    print(paste0(path_scores, file_))
    HEMDAG::Do.GPAV(flat.dir = path_scores, flat.file = file_, 
                   dag.dir = path_dag, 
                   dag.file = paste0("/6239_CAEEL_GO_", dag, "_DAG_STRING_v10.5_20DEC17"), 
                   ann.dir = path_ann, hierScore.dir = "hier.rda",
                   ann.file =  paste0("/6239_CAEEL_GO_", dag, "_ANN_STRING_v10.5_20DEC17"),
                   perf.dir = "perf.rda")
  }
  
}

library(HEMDAG)
path_ <- "/home/kai/Documenti/UNIMI/BioinformaticThesis/Ensemble/"

# DAG path
dag <- "MF"
path_dag <- paste0(path_, "DAG/")
path_ann <- paste0(path_, "ANN/")

# res type
fs <- "PCA/" 
path_scores <- paste0(path_, "scores/", fs)
files <- list.files(path = path_scores, recursive = TRUE)
calculateHIER(files, dag, path_scores, path_dag, path_ann)

