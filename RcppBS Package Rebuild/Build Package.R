library(Rcpp)



Rcpp.package.skeleton("RcppBinarySearch", example_code = FALSE,
                      cpp_files = c("binary_search_forward.cpp",
                                    "binary_search_reverse.cpp"))

Rcpp::compileAttributes("RcppBinarySearch")

## will need to restart R session
install.packages("RcppBinarySearch", 
                 repos = NULL, 
                 type = "source")
