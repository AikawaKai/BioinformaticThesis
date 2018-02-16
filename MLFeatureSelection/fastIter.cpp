#include <Rcpp.h>
#include <iostream>
#include <fstream>
#include <string>

using namespace Rcpp;

// [[Rcpp::export]]
NumericVector fastIterTtest(SEXP csv_name, NumericMatrix x, NumericMatrix y, Function f, std::vector< std::string > classes) {

  NumericVector val(1);
  std::ofstream myfile;
  std::string file_name = as<std::string>(csv_name);
  file_name = file_name.append(".csv");
  myfile.open(file_name.c_str());
  std::string head = "classes\\features";
  // classes
  for(int j=0;j<x.ncol();j++){
    std::ostringstream strs;
    strs << j;
    std::string str_ = strs.str();
    head = head.append(",");
    head = head.append(str_);
  }
  head = head.append("\n");
  myfile<<head;
  for(int i=0;i<y.ncol();i++){
    NumericVector curr_class = y(_,i);
    std::string cur_class = classes.operator[](i);
    std::string to_write = cur_class.append("");
    std::cout<<"start"<<i<<"\n";
    // features
    for(int j=0;j<x.ncol();j++){
      
      NumericVector curr_feature = x(_,j);
      val = f(curr_feature, curr_class);
      std::ostringstream strs;
      strs << val;
      std::string str_ = strs.str();
      to_write.append(","+str_);
    }
    to_write.append("\n");
    myfile<<to_write;
  }
  myfile.close();
  return val;
}