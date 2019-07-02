//sum.cpp
#include <Rcpp.h>
using namespace Rcpp;
#include <unordered_set>
#include <algorithm>

// [[Rcpp::plugins(cpp11)]]


//
int unique_n(Rcpp::CharacterVector x) {
  std::unordered_set<SEXP> tab(x.begin(), x.end());
  return tab.size();
}


// [[Rcpp::export]]
CharacterVector binary_search(CharacterVector cards, CharacterVector dates){
  
  // create character data frame to return
  CharacterVector opt_dates;
  
  //instantiate cards vector for loop subsetting
  CharacterVector cards_loop;
  CharacterVector cards_loop_next;
  
  // after first loop, subset data with found max date
  CharacterVector cards_sub;
  CharacterVector dates_sub;
  
  
  // set variables for loop
  int lo = 0;
  int hi = cards.length()-1;
  int mid;
  
  int n_txns = hi;
  
  int n_cards = unique_n(cards);
  
  
  // check if loop is uneccesary - break out and return results if so
  if (n_cards == 2 && unique_n(cards[Range((n_txns-1), n_txns)]) == 2 ){
    
    opt_dates.push_front(dates[n_txns-1]);
    opt_dates.push_back(dates[n_txns]);
    
    return(opt_dates);
    
    // check if n_txs == n_cards then start_date == min_date & end_date == max_date  
  } else if (n_cards == n_txns + 1) {
    
    opt_dates.push_front(dates[0]);
    opt_dates.push_back(dates[n_txns]);
    
    return(opt_dates);
  }
  

  
  // check if max date is last date in data set
  if(unique_n(cards[Range(0, (n_txns - 1))]) == n_cards - 1){
    
    opt_dates.push_back(dates[n_txns]);
    
    
  } else {
    
    while (lo <= hi){
      
      // integer division returns quotient in c++
      mid = lo + (hi - lo) / 2;
      
      cards_loop = cards[Range(0, mid)];
      cards_loop_next = cards[Range(0, (mid - 1))];
      
      if ( unique_n(cards_loop) == n_cards  &&
           unique_n(cards_loop_next) == n_cards - 1){
        
        opt_dates.push_back(dates[mid]);
        
        // subset data for next loop iteration
        cards_sub = cards_loop;
        dates_sub = dates[Range(0, mid)];
        
        break;
        
      } else if (unique_n(cards_loop) < n_cards){
        
        lo = mid + 1;
      } else {
        
        hi = mid - 1;
      }
      
    }
  
  }
 
 // last index for full subset of data
 n_txns = cards_sub.length() - 1;
  
  lo = 0;
  hi = n_txns;
  
  // check if min date is first date in data set
  if(unique_n(cards_sub[Range(1, n_txns)]) == n_cards - 1){
    
    opt_dates.push_front(dates_sub[0]);
    
    return(opt_dates);
    
  } else {
    
    while(lo <= hi){
      
      // integer division returns quotient in c++
      mid = lo + (hi- lo) / 2;
      
      // search subsets for checking n cards
      cards_loop = cards_sub[Range(mid, n_txns)];
      cards_loop_next = cards_sub[Range((mid + 1) , n_txns)];
      
      if (  unique_n(cards_loop) == n_cards  &&
            unique_n(cards_loop_next) == n_cards - 1){
        
        opt_dates.push_front(dates_sub[mid]);
        
        return(opt_dates);
        
      } else if ( unique_n(cards_loop) < n_cards){
        
        hi = mid + 1;
      } else {
        
        lo = mid - 1;
      }
    }
  
  }// end else
  
  return(opt_dates);
}