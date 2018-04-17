part1 <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/new_6239_CAEEL/6239_CAEEL_GO_"
part2 <- "_ANN_STRING_v10.5_20DEC17.rda"
ontos <- list("BP", "MF", "CC")
for(onto in ontos){
  curr_onto = paste0(part1, onto, part2)
  print(curr_onto)
  load(curr_onto)
  ann <- ann[,colSums(ann)>5]
  print(ncol(ann))
}