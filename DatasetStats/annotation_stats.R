work_path <-"/home/kai/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/DatasetStats/"
part1 <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/new_6239_CAEEL/6239_CAEEL_GO_"
part2 <- "_ANN_STRING_v10.5_20DEC17.rda"
ontos <- list("BP", "MF", "CC")



write_csv_from_ann <- function(ann, work_path, onto){
  col_names = colnames(ann)
  list_val <- list(ncol(ann))
  for(i in 1:ncol(ann)){
    curr_class <- col_names[[i]]
    list_val[[i]] <- sum(ann[,i])
  }
  matrix_val <- matrix(as.matrix(list_val), nrow = 10)
  rownames(matrix_val) <- col_names
  write.csv2(matrix_val, file=paste0(work_path, onto, ".csv"), col.names = FALSE)
}

getPositiveCountFromClasses <- function(onto, part1, part2){
  for(onto in ontos){
    curr_onto = paste0(part1, onto, part2)
    print(curr_onto)
    load(curr_onto)
    ann <- ann[,colSums(ann)>9]
    set.seed(1)
    ann_sample <- sample(colnames(ann), 10)
    ann <- ann[,ann_sample]
    write_csv_from_ann(ann, work_path, onto)
    print(colnames(ann))
    print(ncol(ann))
  }
}

getHistogramsFromClasses <- function(onto, part1, part2){
  for(onto in ontos){
    curr_onto = paste0(part1, onto, part2)
    print(curr_onto)
    load(curr_onto)
    ann <- ann[,colSums(ann)>9]
    print(ncol(ann))
    list_val <- list(ncol(ann))
    for(i in 1:ncol(ann)){
      list_val[[i]] <- sum(ann[,i])
    }
    print(ncol(ann))
    hist(as.numeric(list_val), main = onto, xlim=c(0,ncol(ann)), 
         ylim = c(10,max(as.numeric(list_val))/5), breaks=seq(0, 3000, by=20),
         xlab = "classes", ylab = "num_annotations")
    mean_val <- mean(as.numeric(list_val))
    std_val <- sd(as.numeric(list_val))
    max_val <- max(as.numeric(list_val))
    min_val <- min(as.numeric(list_val))
    list_stats <- list(mean_val=round(mean_val,2), std_val=round(std_val,2), max_val=max_val, min_val=min_val)
    write.csv2(list_stats, file=paste0(work_path, "stats", onto, ".csv"))
  }
}

getPositiveCountFromClasses(onto, part1, part2)
getHistogramsFromClasses(onto, part1, part2)



