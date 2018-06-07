get_info_from_name <- function(file_name){
  res<-unlist(strsplit(file_name, "[.]"))
  onto <- res[7]
  fs <- res[8]
  if(fs == "pearson"){
    fs <- "FS"
    algo <- res[11]
  }else{
    algo <- res[10]
  }
  if(algo=="C5"){
    algo = "C5.0"
  }
  return(c(algo, fs, onto))
}

path <- "/home/kai/Documenti/UNIMI/BioinformaticThesis/Ensemble/hierPerf/"
curr_method <- "GPAV/"
path <- paste0(path, curr_method)
files <- list.files(path = path, recursive = TRUE)
files <- files[lapply(files, function(x){grepl(".rda", x)})==TRUE]
list_ <- list(4)
for(file in files){
  res <- get_info_from_name(file)
  curr_file <- paste0(path, file)
  load(curr_file)
  PRC.flat <- get("PRC.flat")
  PRC.hier <- get("PRC.hier")
  AUC.flat <- get("AUC.flat")
  AUC.hier <- get("AUC.hier")
  curr_row <- c(res[1], PRC.flat[["average"]], PRC.hier[["average"]], AUC.flat[["average"]], AUC.hier[["average"]])
  print(curr_row)
}

