library(factoextra)
path_ <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/" #where to write csv
datasetpath <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/" #where from extract data

#STRING SIMILARITY MATRIX
load(file=paste(datasetpath, "/6239_CAEEL/6239_CAEEL_STRING_NET_v10.5.rda", sep = ""))

W_test <- W[1:2000,]
W_test <- apply(W_test, FUN= function(x) x/1000, MARGIN = c(1,2))
system.time(pca <- prcomp(W_test))
save(pca, file = "./pca.rda")

