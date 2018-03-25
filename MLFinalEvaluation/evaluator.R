SERVER <- FALSE

if(SERVER){
  path <- "/home/modore/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/MLFinalEvaluation/"
}else{
  path <- "/home/kai/Documents/Unimi/Tesi-Bioinformatica/BioinformaticThesis/MLFinalEvaluation/"
}

source(paste0(path,"lib/R_CARET_MODELING.R"))