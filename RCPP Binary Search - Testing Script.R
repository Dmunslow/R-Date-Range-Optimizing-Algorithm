library(data.table)
library(tictoc)
library(Rcpp)


sourceCpp("binary_search.cpp")
sourceCpp("binary_search_EC_FIX.cpp")

sourceCpp("binary_search_reverse_EC_FIX.cpp")
sourceCpp("binary_search_reverse.cpp")


## read RDS
txn_data <- setDT(readRDS("./Algo Testing Txn Data.RDS"))

## create base summary table
#calc n cards and txns by merchant name/MID/MCC

## n cards
txn_data[, n_total_cards := uniqueN(card_number)]

## summary table
cpp_table <- txn_data[, .(n_cards_cpp = uniqueN(card_number),
                          n_txns = .N) , 
                      by = .(merchant_name, merchant_id, mcc, n_total_cards)]


col_order <- c("merchant_id", "merchant_name", "mcc", "n_cards_cpp", "n_total_cards", "n_txns")

setcolorder(cpp_table, col_order)

## forward search dates
f_dates <- data.frame(matrix(ncol = 2, nrow = nrow(cpp_table)))
b_dates <- data.frame(matrix(ncol = 2, nrow = nrow(cpp_table)))

## col names
date_names <- c("min_date", "max_date")
colnames(f_dates) <- date_names
colnames(b_dates) <- date_names

## order txn data by merchant id, and date
txn_data <- txn_data[order(merchant_id, txn_date)]


txn_data$char_dates <- as.character(txn_data$txn_date)


## create test data sets

test_data <- txn_data[merchant_id == cpp_table$merchant_id[1]]


## create data for min date as first row edge case
min_date_first_row <- test_data[1,] 
min_date_first_row$card_number[1] <- "808080801999999"

test_data_mdfr <- rbind(min_date_first_row, test_data)

## test cpp reverse - test case works, other case breaks
binary_search_reverse(test_data_mdfr$card_number, test_data_mdfr$txn_date)
binary_search_reverse_test(test_data_mdfr$card_number, test_data_mdfr$txn_date)


binary_search_test(test_data_mdfr$card_number, test_data_mdfr$txn_date)
binary_search(test_data_mdfr$card_number, test_data_mdfr$txn_date)

## create edge case data, 2 cards, last row and 2nd to last row as range

# get unique cards
unique(test_data$card_number)

cards <- c("808080801000007",  "808080801000018")

test_data_2cards_end <- test_data[card_number %in% cards]

test_data_2cards_end <- test_data_2cards_end[1:28,]

## run test
binary_search_reverse(test_data_2cards_end$card_number, test_data_2cards_end$txn_date)
binary_search_reverse_test(test_data_2cards_end$card_number, test_data_2cards_end$txn_date)

binary_search_test(test_data_2cards_end$card_number, test_data_2cards_end$txn_date)

tic()
for (i in 1:nrow(cpp_table)){

  ## txn data for search
  txn_data_loop <- txn_data[merchant_id == cpp_table$merchant_id[i]]
  
  ans <- binary_search(txn_data_loop$card_number, txn_data_loop$char_dates)
  ans2 <- binary_search_reverse(txn_data_loop$card_number, txn_data_loop$char_dates)
  
  b_dates[i,1] <- ans[1]
  b_dates[i,2] <- ans[2]
  
  
  f_dates[i,1] <- ans2[1]
  f_dates[i,2] <- ans2[2]
  
  
 
  
}

toc()