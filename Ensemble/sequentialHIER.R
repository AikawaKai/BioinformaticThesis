executeALGO <- function(path_scores, file_, path_dag, dag.file, path_ann, ann.file, rec.levels,
                        hierPerfPath, hierScoresPath, hierAlgo, bottomup = NULL){
  if(bottomup == "threshold" || bottomup == "weighted.threshold.free"){
    metric ="FMAX"
  }else{
    metric = NULL
  }
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
  if(hierAlgo=="TPR-DAG"){
    Do.TPR.DAG(flat.dir = path_scores, flat.file = file_,  dag.dir = path_dag, dag.file = dag.file, 
               ann.dir = path_ann, hierScore.dir = hierScoresPath, ann.file = ann.file,  
               perf.dir = hierPerfPath, rec.levels = rec.levels, norm.type = "MaxNorm", n.round = 3,
               f.criterion = "F", norm = FALSE, folds = NULL, seed = 1, bottomup = bottomup,
               topdown = "HTD", metric = metric)
  }
  if(hierAlgo=="ISO-TPR"){
    Do.TPR.DAG(flat.dir = path_scores, flat.file = file_,  dag.dir = path_dag, dag.file = dag.file, 
               ann.dir = path_ann, hierScore.dir = hierScoresPath, ann.file = ann.file,  
               perf.dir = hierPerfPath, rec.levels = rec.levels, norm.type = "MaxNorm", n.round = 3,
               f.criterion = "F", norm = FALSE, folds = NULL, seed = 1, bottomup = bottomup,
               topdown = "GPAV", parallel = TRUE, ncores = 5, metric = metric)
  }
  if(hierAlgo=="TPR-W"){
    Do.TPR.DAG(flat.dir = path_scores, flat.file = file_,  dag.dir = path_dag, dag.file = dag.file, 
               ann.dir = path_ann, hierScore.dir = hierScoresPath, ann.file = ann.file,  
               perf.dir = hierPerfPath, rec.levels = rec.levels, norm.type = "MaxNorm", n.round = 3,
               f.criterion = "F", norm = FALSE, folds = NULL, seed = 1, bottomup = "weighted.threshold.free",
               topdown = "HTD", metric = metric, positive = "children")
  }
  
}

getFS <- function(file_name){
  if(grepl(pattern = ".PCA.", file_name)){
    return("PCA")
  }else{
    return("FS")
  }
}

calculateHIER <- function(files, path_, path_dag, path_ann, hierAlgo, bottomup){
  rec.levels <- seq(from=0.1, to=1, by=0.1);
  for(file_ in files){
    file_ <- substring(file_, 1, nchar(file_)-4)
    split_ <- unlist(strsplit(file_, "[.]"))
    dag <- split_[5]
    fs <- getFS(file_)
    path_scores <- paste0(path_, "scores/", fs, "/")
    dag.file = paste0("/6239_CAEEL_GO_", dag, "_DAG_STRING_v10.5_20DEC17")
    ann.file =  paste0("/6239_CAEEL_GO_", dag, "_ANN_STRING_v10.5_20DEC17")
    print("[INFO] Current File")
    print(file_)
    print("[INFO] Current Extracted DAG")
    print(dag)
    print("[INFO] Current Extracted FS")
    print(fs)
    hierScoresPath <- paste0(path_, "/hierScores/", hierAlgo, bottomup, "/")
    hierPerfPath <- paste0(path_, "/hierPerf/", hierAlgo, bottomup, "/")
    executeALGO(path_scores, file_, path_dag, dag.file, path_ann, ann.file, rec.levels, hierPerfPath,
                hierScoresPath, hierAlgo, bottomup = bottomup)
  }
  
}

library(HEMDAG)

SERVER <- FALSE
args <- commandArgs(trailingOnly = TRUE)
if(length(args)==1){
  hierAlgo <- args[1]
  bottomup <- NULL
}else{
  hierAlgo <- args[1]
  bottomup <- args[2]
}

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

# for(dag in dags){
#   for(fs in feat_select){
#     path_scores <- paste0(path_, "scores/", fs, "/")
#     files <- list.files(path = path_scores, recursive = TRUE)
#     files <- files[lapply(files, function(x){grepl("naive_bayes", x)})==TRUE]
#     calculateHIER(files, dag, path_, path_scores, path_dag, path_ann, hierAlgo)
#   }
# }

basic_list <- list()
for(dag in dags){
  for(fs in feat_select){
  path_scores <- paste0(path_, "scores/", fs, "/")
  files <- list.files(path = path_scores, recursive = TRUE)
  files <- files[lapply(files, function(x){grepl(dag, x)})==TRUE]
  basic_list <- c(basic_list, files)
    }
}
basic_list <- basic_list[0:length(basic_list)]
calculateHIER(basic_list, path_, path_dag, path_ann, hierAlgo, bottomup)
