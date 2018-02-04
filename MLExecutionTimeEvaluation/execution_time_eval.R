library(parallel)
# loading lib
source("/home/kai/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/MLExecutionTimeEvaluation/lib/utility.R")

#paths
path_ <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/" #where to write csv
datasetpath <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/" #where to extract data

#STRING SIMILARITY MATRIX
load(file=paste(datasetpath, "/6239_CAEEL/6239_CAEEL_STRING_NET_v10.5.rda", sep = ""))

test =TRUE


# only when testing
if(test){
  W <- W[seq(1,2000),]
}

ontologies <- c("/6239_CAEEL/6239_CAEEL_GO_BP_ANN_STRING_v10.5_20DEC17.rda",
                "/6239_CAEEL/6239_CAEEL_GO_MF_ANN_STRING_v10.5_20DEC17.rda",
                "/6239_CAEEL/6239_CAEEL_GO_CC_ANN_STRING_v10.5_20DEC17.rda")

ont_name <- c("BP", "MF", "CC")
algorithms <- c("svmLinear", "xgbLinear") 
#"svmRadial",, "mlp", "logitBoost")

params <- rbind.fill(data.frame(C = c(.25)),
                     #data.frame(.C = c(.25)),
                     data.frame(nrounds = 10, eta = c(0.01), max_depth = c(2), gamma = 1))
                     #data.frame(size=5),
                     #data.frame(nIter=50))

#starting cluster
no_cores <- detectCores() -1
cl <- makeCluster(no_cores, errfile="./errParSeq.txt", outfile=paste(path_, "out.txt", sep=""), type = "FORK")

#parallel execution
parLapply(cl, seq(1,length(algorithms)), function(x) c(timeEstimate(ont_name, ontologies, datasetpath, 
                                                                    algorithms[[x]], params[x,],
                                                                    1, test, 10)))
stopCluster(cl)


param <- data.frame(C = c(.25))
param[1,"C"]
algo <- "svmLinear"
res <- getGridParam(param, algo)
res
