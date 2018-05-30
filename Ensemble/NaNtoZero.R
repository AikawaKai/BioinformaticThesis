path_ <- "/home/kai/Documenti/UNIMI/BioinformaticThesis/Ensemble/"
dags <- c("BP", "MF", "CC")
feat_select <- c("PCA", "FS")

basic_list <- list()
for(dag in dags){
  for(fs in feat_select){
    path_scores <- paste0(path_, "scores/", fs, "/")
    files <- list.files(path = path_scores, recursive = TRUE)
    files <- files[lapply(files, function(x){grepl(dag, x)})==TRUE]
    basic_list <- c(basic_list, files)
  }
}
files <- basic_list[lapply(basic_list, function(x){grepl("naive_bayes", x)})==TRUE]
files <- files[lapply(files, function(x){grepl(".feature.", x)})==TRUE]
files
path_to_load <- paste0(path_, "/scores/FS/")
path_to_load
for(file in files){
  cur_path <- paste0(path_to_load, file)  
  load(cur_path)
  S <- get("S")
  x <- which(is.na(S)) ## S: matrice scores flat
  S[x] <- 0
  save(S, file = cur_path)
}
