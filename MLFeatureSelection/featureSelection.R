source("/home/kai/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/MLFeatureSelection/lib/utility.R")

path_ <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/" #where to write csv
datasetpath <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/" #where to extract data

#STRING SIMILARITY MATRIX
load(file=paste(datasetpath, "/6239_CAEEL/6239_CAEEL_STRING_NET_v10.5.rda", sep = ""))
ontologies <- c("/6239_CAEEL/6239_CAEEL_GO_BP_ANN_STRING_v10.5_20DEC17.rda",
                "/6239_CAEEL/6239_CAEEL_GO_MF_ANN_STRING_v10.5_20DEC17.rda",
                "/6239_CAEEL/6239_CAEEL_GO_CC_ANN_STRING_v10.5_20DEC17.rda")

ont_name <- c("BP", "MF", "CC")

load(file=paste(datasetpath, ontologies[[1]], sep = ""))
ann <- ann[,colSums(ann)>9]
#classes iter i

fastIterTtest(W, ann, ptestCalculation)
iterTtestCalculation(W, ann)





