checkResults <- function(path_file, fs){
  if( fs == 'FS/'){
    algo_index <- 9
  }else{
    alo_index <- 8
  }
  str_split <- unlist(strsplit(path_file, "[.]"))
  type_ <- str_split[5]
  algo <- str_split[algo_index]
  print(algo)
  print(type_)
  load(path_file)
  print(S[[1]][[1]])
}



library(HEMDAG)
path_ <- "/home/kai/Documenti/UNIMI/BioinformaticThesis/Ensemble/scores/"
fs <- "FS/"
path_c <-paste0(path_, type_) 
files <- list.files(path = path_c, recursive = TRUE)
for(file in files){
  checkResults(paste0(path_c, file), fs)
}
