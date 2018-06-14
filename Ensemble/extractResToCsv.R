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

updateList <- function(list1, algo, fs, onto, AUC.flat, AUC.hier, PRC.flat, PRC.hier){
  list1 <- data.frame(list1)
  list1[,ncol(list1)+1] <- AUC.flat[["per.class"]]
  names(list1)[ncol(list1)] <- paste0(algo, "_AUC.flat_", fs)
  list1[,ncol(list1)+1] <- AUC.hier[["per.class"]]
  names(list1)[ncol(list1)] <- paste0(algo, "_AUC.hier_", fs)
  list1[,ncol(list1)+1] <- PRC.flat[["per.class"]]
  names(list1)[ncol(list1)] <- paste0(algo, "_PRC.flat_", fs)
  list1[,ncol(list1)+1] <- PRC.hier[["per.class"]]
  names(list1)[ncol(list1)] <- paste0(algo, "_PRC.hier_", fs)
  return(list1)
}

updateList1 <- function(list1, algo, fs, onto, FMM.flat, FMM.hier){
  list1[,ncol(list1)+1] <- FMM.flat[["per.example"]][,4]
  names(list1)[ncol(list1)] <- paste0(algo, "_FMM.flat_", fs)
  list1[,ncol(list1)+1] <- FMM.hier[["per.example"]][,4]
  names(list1)[ncol(list1)] <- paste0(algo, "_FMM.hier_", fs)
  return(list1)
}


methods <- c("TPR-DAGthreshold.free", "ISO-TPRthreshold.free", "HTD", "GPAV", "TPR-DAGthreshold")
for(curr_method in methods){
  path <- "/home/kai/Documenti/UNIMI/BioinformaticThesis/Ensemble/hierPerf/"
  path <- paste0(path, curr_method, "/")
  files <- list.files(path = path, recursive = TRUE)
  files <- files[lapply(files, function(x){grepl(".rda", x)})==TRUE]
  list_ <- list(4)
  to_write <- data.frame()
  bp_df <- data.frame(matrix(0, nrow = 1334))
  mf_df <- data.frame(matrix(0, nrow = 185))
  cc_df <- data.frame(matrix(0, nrow = 220))
  bp_df_fmm <- data.frame(matrix(0, nrow = 2597 ))
  mf_df_fmm <- data.frame(matrix(0, nrow = 1806))
  cc_df_fmm <- data.frame(matrix(0, nrow = 1924 ))
  for(file in files){
    res <- get_info_from_name(file)
    curr_file <- paste0(path, file)
    load(curr_file)
    PRC.flat <- get("PRC.flat")
    PRC.hier <- get("PRC.hier")
    AUC.flat <- get("AUC.flat")
    AUC.hier <- get("AUC.hier")
    FMM.flat <- get("FMM.flat")
    FMM.hier <- get("FMM.hier")
    curr_row<- data.frame(res[1], res[2], res[3], PRC.flat[["average"]], PRC.hier[["average"]], 
                          AUC.flat[["average"]], AUC.hier[["average"]])
    names(curr_row)<-c("algo", "fs", "onto", "PRC.flat", "PRC.hier", "AUC.flat", "AUC.hier")
    to_write <- rbind(to_write, curr_row)
    
    if(res[[3]]=="BP"){
      bp_df <- updateList(bp_df, res[[1]], res[[2]], res[[3]], AUC.flat, AUC.hier, PRC.flat, PRC.hier)
      bp_df_fmm <- updateList1(bp_df_fmm, res[[1]], res[[2]], res[[3]], FMM.flat, FMM.hier)
    }else if(res[[3]]=="MF"){
      mf_df <- updateList(mf_df, res[[1]], res[[2]], res[[3]], AUC.flat, AUC.hier, PRC.flat, PRC.hier)
      mf_df_fmm <- updateList1(mf_df_fmm, res[[1]], res[[2]], res[[3]], FMM.flat, FMM.hier)
    }else{
      cc_df <- updateList(cc_df, res[[1]], res[[2]], res[[3]], AUC.flat, AUC.hier, PRC.flat, PRC.hier)
      cc_df_fmm <- updateList1(cc_df_fmm, res[[1]], res[[2]], res[[3]], FMM.flat, FMM.hier)
    }
  }
  #print(to_write)
  file_to_write <- paste0(path, curr_method, ".csv")
  file_to_writeBP <- paste0(path, "BP_", curr_method, ".csv")
  file_to_writeMF <- paste0(path, "MF_", curr_method, ".csv")
  file_to_writeCC <- paste0(path, "CC_", curr_method, ".csv")
  file_to_writeBP_FMM <- paste0(path, "BP_", curr_method, "_FMM.csv")
  file_to_writeMF_FMM <- paste0(path, "MF_", curr_method, "_FMM.csv")
  file_to_writeCC_FMM <- paste0(path, "CC_", curr_method, "_FMM.csv")
  write.table(to_write, file = file_to_write, sep="\t", row.names = FALSE)
  write.table(bp_df[,2:ncol(bp_df)], file = file_to_writeBP, sep="\t", row.names = FALSE)
  write.table(mf_df[,2:ncol(mf_df)], file = file_to_writeMF, sep="\t", row.names = FALSE)
  write.table(cc_df[,2:ncol(cc_df)], file = file_to_writeCC, sep="\t", row.names = FALSE)
  write.table(bp_df_fmm[,2:ncol(bp_df_fmm)], file = file_to_writeBP_FMM, sep="\t", row.names = FALSE)
  write.table(mf_df_fmm[,2:ncol(mf_df_fmm)], file = file_to_writeMF_FMM, sep="\t", row.names = FALSE)
  write.table(cc_df_fmm[,2:ncol(cc_df_fmm)], file = file_to_writeCC_FMM, sep="\t", row.names = FALSE)
}
