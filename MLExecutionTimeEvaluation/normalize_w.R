library(caret)
datasetpath <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/"
load(file=paste(datasetpath, "/6239_CAEEL/6239_CAEEL_STRING_NET_v10.5.rda", sep = ""))
W <- lapply(W, FUN= function(x) x/1000)
save(W, file = "./normalized_w.rda")