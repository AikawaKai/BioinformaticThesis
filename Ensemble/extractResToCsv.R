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
curr_method <- "ISO-TPRthreshold.free"
# curr_method <- "HTD"
path <- paste0(path, curr_method, "/")
files <- list.files(path = path, recursive = TRUE)
files <- files[lapply(files, function(x){grepl(".rda", x)})==TRUE]
list_ <- list(4)
to_write <- data.frame()
for(file in files){
  res <- get_info_from_name(file)
  curr_file <- paste0(path, file)
  load(curr_file)
  PRC.flat <- get("PRC.flat")
  PRC.hier <- get("PRC.hier")
  AUC.flat <- get("AUC.flat")
  AUC.hier <- get("AUC.hier")
  curr_row<- data.frame(res[1], res[2], res[3], PRC.flat[["average"]], PRC.hier[["average"]], 
                AUC.flat[["average"]], AUC.hier[["average"]])
  names(curr_row)<-c("algo", "fs", "onto", "PRC.flat", "PRC.hier", "AUC.flat", "AUC.hier")
  to_write <- rbind(to_write, curr_row)
}
print(to_write)
file_to_write <- paste0(path, curr_method, ".csv")
write.table(to_write, file = file_to_write, sep="\t", row.names = FALSE)