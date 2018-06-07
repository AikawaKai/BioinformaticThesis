
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
  print("#######")
  print(onto)
  print(algo)
  print(fs)
}



path <- "/home/kai/Documenti/UNIMI/BioinformaticThesis/Ensemble/hierPerf/"
curr_method <- "GPAV"
path <- paste0(path, curr_method)
files <- list.files(path = path, recursive = TRUE)
files <- files[lapply(files, function(x){grepl(".rda", x)})==TRUE]
for(file in files){
  get_info_from_name(file)
}

