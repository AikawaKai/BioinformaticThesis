getInfoFromName<-function(name){
  
}

getPerfFlat<-function(path_file, path_, files, onto, type_){
  res <- list(12)
  i <- 0
  algo_names <- list(12)
  if(type_ == "PCA"){
    index <- 8
  }else{
    index <- 9
  }
  for(file in files){
    print(file)
    load(paste0(path_, "/", file))
    AUC.flat <- get("AUC.flat")
    PRC.flat <- get("PRC.flat")
    names_ <- names(AUC.flat[[2]])
    auc_scores <- AUC.flat[[2]]
    prc_scores <- PRC.flat[[2]]
    i <- i + 1
    res[i] <- list(auc_scores)
    split_ <- unlist(strsplit(file, "[.]"))
    algo_names[i] <- split_[[index]]
    
    
  }
  names(res) <- algo_names
  # print(names_)
  #res["classes"] <- names_
  write.table(res, file=paste0(path_file,"/", onto, "_", type_, ".csv"), 
            sep="\t", dec=".", row.names = FALSE)
  #print(names_)
}



path_ <- "/home/kai/Documenti/UNIMI/BioinformaticThesis/MLFinalEvaluation/"
sel_type <- "FS"
onto <- "CC"
path_to_read <- paste0(path_, "/perf/", sel_type)
path_to_read
files <- list.files(path = path_to_read, recursive = TRUE)
files <- files[lapply(files, function(x){grepl(onto, x)})==TRUE]
files
getPerfFlat(path_, path_to_read, files, onto, sel_type)
