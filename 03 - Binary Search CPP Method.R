library(data.table)
library(tictoc)
library(Rcpp)


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

tic()

for (i in 1:nrow(cpp_table)){
  
  ## subset mid for future subsetting
  mid_loop <- cpp_table$merchant_id[i]
  
  ## txn data for search
  txn_data_loop <- txn_data[merchant_id == mid_loop]
  
  ## n cards for while condition
  n_cards_mid <- cpp_table[ merchant_id == mid_loop, n_cards_cpp]
  n_cards_left <- n_cards_mid
  
  lo <- 1
  hi <- nrow(txn_data_loop)
  
  while(lo <= hi){
    
    mid <- lo + (hi- lo) %/% 2
    
    if ( uniqueN(txn_data_loop$card_number[1:mid]) == n_cards_mid  &
        uniqueN(txn_data_loop$card_number[1:(mid-1)]) == n_cards_mid - 1){
      
      b_dates$max_date[i] <- as.character(txn_data_loop$txn_date[mid])
      
      break
      
    } else if ( uniqueN(txn_data_loop$card_number[1:mid]) < n_cards_mid){
      
      lo = mid + 1;
    } else {
      
      hi = mid - 1;
    }
  }
  
  ## create data set with found max date
  txn_max_loop <- txn_data_loop[txn_date <= b_dates$max_date[i]]
  
  nrow <- nrow(txn_max_loop)
  
  lo <- 1
  hi <- nrow(txn_max_loop)
  
  while(lo <= hi){
    
    mid <- lo + (hi- lo) %/% 2
    
    if ( uniqueN(txn_max_loop$card_number[mid:nrow]) == n_cards_mid  &
         uniqueN(txn_max_loop$card_number[(mid+1):nrow]) == n_cards_mid - 1){
      
      b_dates$min_date[i] <- as.character(txn_max_loop$txn_date[mid])
      
      break
      
    }else if ( uniqueN(txn_max_loop$card_number[mid:nrow]) < n_cards_mid){
      
      hi = mid + 1;
    } else {
      
      lo = mid - 1;
    }
  }
  
  ## reverse reverse reverse ================================================
  
  nrow <- nrow(txn_data_loop)
  
  lo <- 1
  hi <- nrow(txn_data_loop)
  
  while(lo <= hi){
    
    mid <- lo + (hi- lo) %/% 2
    
    if ( uniqueN(txn_data_loop$card_number[mid:nrow]) == n_cards_mid  &
         uniqueN(txn_data_loop$card_number[(mid+1):nrow]) == n_cards_mid - 1){
      
      f_dates$min_date[i] <- as.character(txn_data_loop$txn_date[mid])
      
      break
      
    }else if ( uniqueN(txn_data_loop$card_number[mid:nrow]) < n_cards_mid){
      hi = mid - 1;
      
    } else {
      lo = mid + 1;
      
    }
  }
  
  ## create data set with found min date
  txn_min_loop <- txn_data_loop[txn_date >= f_dates$min_date[i]]
  
  nrow <- nrow(txn_min_loop)
  
  lo <- 1
  hi <- nrow(txn_min_loop)
  
  while(lo <= hi){
    
    mid <- lo + (hi- lo) %/% 2
    
    if ( uniqueN(txn_min_loop$card_number[1:mid]) == n_cards_mid  &
         uniqueN(txn_min_loop$card_number[1:(mid-1)]) == n_cards_mid - 1){
      
      f_dates$max_date[i] <- as.character(txn_min_loop$txn_date[mid])
      
      break
      
    } else if ( uniqueN(txn_min_loop$card_number[1:mid]) < n_cards_mid){
      
      lo = mid + 1;
    } else {
      
      hi = mid - 1;
    }
  }
}

toc()

cpp_table$f_max_date <- f_dates$max_date


