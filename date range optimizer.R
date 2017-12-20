
library(lubridate)
library(readr)
library(data.table)


date_range_data <- read_csv("E:/R Programming resources/R Data Sets/Date Range Data Set.csv")
date_range_table_master <- read_csv("E:/R Programming resources/R Data Sets/Date Range Table.csv")



### Convert data types

date_range_data$Date <- as.Date(date_range_data$Date)



### Step 1: Create CPP Table using data.table

dt_cpp_table <- setDT(date_range_data)[,total_individuals := uniqueN(individual_id),][,.(num_individuals = uniqueN(individual_id),
                                                                                         num_txns = .N,
                                                                                         min_date = min(Date),
                                                                                         max_date = max(Date),
                                                                                        date_range = difftime(max(Date), min(Date) , units = c("days")))
                                                                                        ,by = .(merchant_id, total_individuals)][num_individuals > 1][order(-num_individuals)]

dt_cpp_table <- setcolorder(dt_cpp_table, c("merchant_id", "num_individuals", 'total_individuals', 'num_txns', 'min_date', 'max_date', 'date_range'))


master_merchants <- unique(date_range_table_master$merchant_id)


dt_cpp_table <- dt_cpp_table[dt_cpp_table$merchant_id %in% master_merchants,]


dt_cpp_table$loop_id <- 1:length(dt_cpp_table$merchant_id)

date_range_data$loop_id <- dt_cpp_table[match(date_range_data$merchant_id,dt_cpp_table$merchant_id),8]



## create empty data frame for optimized date range

optimized <- matrix(nrow = length(dt_cpp_table$merchant_id), ncol = 3)

num_merchants <- length(dt_cpp_table$merchant_id)

i = 71

### Initiate for loop

for(i in 1:num_merchants){
    
    ## Subset data, arranged by date
    all_txns <- date_range_data[date_range_data$loop_id == i,]
    
    ## count cards in DF for given merchant
    total_cards <- length(unique(all_txns$individual_id))
    n_cards <- length(unique(all_txns$individual_id))
    
    ## Set max date
    min_date <- min(all_txns$Date)
    new_min <- min(all_txns$Date)
    
    max_date <- max(all_txns$Date)
    new_max <- max(all_txns$Date)
    
    ## While loop to set min date
    while(total_cards == n_cards){
        
        # update min date
        min_date <- new_min
        
        new_min_data <- all_txns[all_txns$Date > min_date,]
        
        #count number of cards in new DF
        n_cards <- length(unique(new_min_data$individual_id))
        
        new_min <- min(new_min_data$Date)
    } # end while loop
    
    
    ## subset data to reflect new min date
    min_txns <- all_txns[all_txns$Date >= min_date,]
    
    ## reset n_card to number of cards in DF
    n_cards <- length(unique(all_txns$individual_id))

    ## While loop to set max date
    while(total_cards == n_cards){
        
        # update max date
        max_date <- new_max
        
        new_max_data <- min_txns[min_txns$Date < max_date,]
        
        #count number of cards in new DF
        n_cards <- length(unique(new_max_data$individual_id))
        
        # update new max date of DF
        new_max <- max(new_max_data$Date)
    } # end while loop
    
    
    ##create final DF
    final_data <- all_txns[all_txns$Date >= min_date & all_txns$Date <= max_date,]
    
    
    ## fill matrix values
   
    #min date
    optimized[i, 1] <- as.character(min(final_data$Date))
    
    #max date
    optimized[i, 2] <- as.character(max(final_data$Date))
    
    #date range
    optimized[i, 3] <- difftime(max(final_data$Date),min(final_data$Date), c("days"))
    
} # end for loop





q


