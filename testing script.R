library(data.table)
library(Rcpp)

dat <- fread("./baddata2.csv")

dat <- dat[, c(2,3)]

dat$cid <- as.character(dat$cid)

#Rcpp::sourceCpp("E:/Projects/RCPP-Binary-Search-Package/rcpp_forward_final_v2.cpp")

Rcpp::sourceCpp("E:/Projects/RCPP-Binary-Search-Package/rcpp_forward_test.cpp")

Rcpp::sourceCpp("E:/Projects/RCPP-Binary-Search-Package/binary_search_reverse_test.cpp")


binary_search_reverse(dat$cid, dat$Date)
