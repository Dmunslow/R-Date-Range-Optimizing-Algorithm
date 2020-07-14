library(Rcpp)
library(RcppBinarySearch)


Rcpp.package.skeleton("RcppBinarySearch", example_code = FALSE,
                      cpp_files = c("binary_search_forward.cpp",
                                    "binary_search_reverse.cpp"))

Rcpp::compileAttributes("RcppBinarySearch")

## will need to restart R session - need to grab package from library
install.packages("RcppBinarySearch", 
                 repos = NULL, 
                 type = "source",
                 destdir = "E:/Projects/RCPP-Binary-Search-Package/RcppBS Package Rebuild/Built Package")

RcppBinarySearch::binary_search(
  
)


library(data.table)
test_dat <- fread("E:/Projects/RCPP-Binary-Search-Package/baddata.csv")


RcppBinarySearch::binary_search(test_dat$cid, test_dat$Date)
