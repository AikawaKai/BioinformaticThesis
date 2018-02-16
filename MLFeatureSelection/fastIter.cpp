#include <Rcpp.h>
#include <iostream>
#include <fstream>
#include <string>

using namespace Rcpp;

// [[Rcpp::export]]
NumericVector fastIterTtest(NumericMatrix x, NumericMatrix y, Function f) {
  NumericVector val(1);
  std::ofstream myfile;
  myfile.open("example.csv");
  for(int i=0;i<y.length();i++){
    NumericVector curr_class = y(_,i);
    String to_write = "";
    for(int j=0;j<x.length();j++){
      NumericVector curr_feature = x(_,j);
      val = f(curr_feature, curr_class);
      //std::cout<<val<<"\n";
    }
  }
  return val;
}