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
# curr_method <- "ISO-TPRthreshold.free"
# curr_method <- "HTD"
# curr_method <- "GPAV"
curr_method <- "TPR-DAGthreshold.free"
path <- paste0(path, curr_method, "/")
files <- list.files(path = path, recursive = TRUE)
files <- files[lapply(files, function(x){grepl(".rda", x)})==TRUE]
list_ <- list(4)
to_write <- data.frame()
bp_df <- data.frame(matrix(0, nrow = 1334))
mf_df <- data.frame(matrix(0, nrow = 185))
cc_df <- data.frame(matrix(0, nrow = 220))
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
  
  if(res[[3]]=="BP"){
    bp_df[,ncol(bp_df)+1] = AUC.flat[["per.class"]]
    names(bp_df)[ncol(bp_df)] = paste0(res[1], "_AUC.flat_", res[[2]])
    bp_df[,ncol(bp_df)+1] = AUC.hier[["per.class"]]
    names(bp_df)[ncol(bp_df)] = paste0(res[1], "_AUC.hier_", res[[2]])
    bp_df[,ncol(bp_df)+1] = PRC.flat[["per.class"]]
    names(bp_df)[ncol(bp_df)] = paste0(res[1], "_PRC.flat_", res[[2]])
    bp_df[,ncol(bp_df)+1] = PRC.hier[["per.class"]]
    names(bp_df)[ncol(bp_df)] = paste0(res[1], "_PRC.hier_", res[[2]])
  }else if(res[[3]]=="MF"){
    mf_df[,ncol(mf_df)+1] = AUC.flat[["per.class"]]
    names(mf_df)[ncol(mf_df)] = paste0(res[1], "_AUC.flat_", res[[2]])
    mf_df[,ncol(mf_df)+1] = AUC.hier[["per.class"]]
    names(mf_df)[ncol(mf_df)] = paste0(res[1], "_AUC.hier_", res[[2]])
    mf_df[,ncol(mf_df)+1] = PRC.flat[["per.class"]]
    names(mf_df)[ncol(mf_df)] = paste0(res[1], "_PRC.flat_", res[[2]])
    mf_df[,ncol(mf_df)+1] = PRC.hier[["per.class"]]
    names(mf_df)[ncol(mf_df)] = paste0(res[1], "_PRC.hier_", res[[2]])
  }else{
    cc_df[,ncol(cc_df)+1] = AUC.flat[["per.class"]]
    names(cc_df)[ncol(cc_df)] = paste0(res[1], "_AUC.flat_", res[[2]])
    cc_df[,ncol(cc_df)+1] = AUC.hier[["per.class"]]
    names(cc_df)[ncol(cc_df)] = paste0(res[1], "_AUC.hier_", res[[2]])
    cc_df[,ncol(cc_df)+1] = PRC.flat[["per.class"]]
    names(cc_df)[ncol(cc_df)] = paste0(res[1], "_PRC.flat_", res[[2]])
    cc_df[,ncol(cc_df)+1] = PRC.hier[["per.class"]]
    names(cc_df)[ncol(cc_df)] = paste0(res[1], "_PRC.hier_", res[[2]])
  }
}
print(to_write)
file_to_write <- paste0(path, curr_method, ".csv")
file_to_writeBP <- paste0(path, "BP_", curr_method, ".csv")
file_to_writeMF <- paste0(path, "MF_", curr_method, ".csv")
file_to_writeCC <- paste0(path, "CC_", curr_method, ".csv")
write.table(to_write, file = file_to_write, sep="\t", row.names = FALSE)
write.table(bp_df[,2:ncol(bp_df)], file = file_to_writeBP, sep="\t", row.names = FALSE)
write.table(mf_df[,2:ncol(mf_df)], file = file_to_writeMF, sep="\t", row.names = FALSE)
write.table(cc_df[,2:ncol(cc_df)], file = file_to_writeCC, sep="\t", row.names = FALSE)