//sum.cpp
#include <Rcpp.h>
using namespace Rcpp;
#include <unordered_set>
#include <algorithm>

// [[Rcpp::plugins(cpp11)]]


//
int unique_N(Rcpp::CharacterVector x) {
  std::unordered_set<SEXP> tab(x.begin(), x.end());
  return tab.size();
}

// [[Rcpp::export]]
CharacterVector binary_search_reverse(CharacterVector cards, CharacterVector dates){

  // create character data frame to return
  CharacterVector opt_dates;

  //instantiate cards vector for loop subsetting
  CharacterVector cards_loop;
  CharacterVector cards_loop_next;

  // after first loop, subset data with found max date
  CharacterVector cards_sub;
  CharacterVector dates_sub;

  // card count for loop
  int n_cards = unique_N(cards);

  // set variables for loop
  int n_txns = cards.length() - 1;
  int lo = 0;
  int hi = n_txns;
  int mid;

  // check if loop is uneccesary - break out and return results if so
  if (n_cards == 2 && unique_N(cards[Range((n_txns-1), n_txns)]) == 2 ){

    opt_dates.push_front(dates[n_txns-1]);
    opt_dates.push_back(dates[n_txns]);

    return(opt_dates);

  // check if n_txs == n_cards then start_date == min_date & end_date == max_date
  } else if (n_cards == n_txns + 1) {

    opt_dates.push_front(dates[0]);
    opt_dates.push_back(dates[n_txns]);

    return(opt_dates);
  }

  // check if min date is first date in data set
  if(unique_N(cards[Range(1, n_txns)]) == n_cards - 1){

    opt_dates.push_front(dates[0]);

    cards_sub = cards;
    dates_sub = dates;

  } else {

    while(lo <= hi){
        
      // integer division returns quotient in c++
      mid = lo + (hi- lo) / 2;

      // search subsets for checking n cards
      cards_loop = cards[Range(mid, n_txns)];
      cards_loop_next = cards[Range((mid + 1) , n_txns)];

      if (  unique_N(cards_loop) == n_cards  &&
            unique_N(cards_loop_next) == n_cards - 1){

        opt_dates.push_front(dates[mid]);
        
        //if ncards == 2, then upper bound is mid + 1, push back and return data
        if(n_cards == 2){
          
          opt_dates.push_back(dates[mid+1]);
          
          return(opt_dates);
          
        }

        // subset data for next loop iteration
        cards_sub = cards_loop;
        dates_sub = dates[Range(mid, n_txns)];

        break;

      } else if ( unique_N(cards_loop) < n_cards){

        hi = mid + 1;

        
      } else {

        lo = mid - 1;

      }
    }

  } // end else


  // reset low and high
  lo = 0;
  hi = cards_sub.length()-1;
  n_txns = cards_sub.length() - 1;
  
  CharacterVector cards_sub_m1 =  cards_sub[Range(0, (hi - 1))];
  
  // check if max date is last date in data set
  if(unique_N(cards_sub_m1) == n_cards - 1){

    opt_dates.push_back(dates_sub[n_txns]);

    return(opt_dates);

  } else {

    while (lo <= hi){

      // integer division returns quotient in c++
      mid = lo + (hi - lo) / 2;

      cards_loop = cards_sub[Range(0, mid)];
      cards_loop_next = cards_sub[Range(0, (mid - 1))];

      if ( unique_N(cards_loop) == n_cards  &&
           unique_N(cards_loop_next) == n_cards - 1){

        opt_dates.push_back(dates_sub[mid]);

        break;

      } else if (unique_N(cards_loop) < n_cards){

        lo = mid + 1;
      } else {

        hi = mid - 1;
      }
    }

  } // end else


  return(opt_dates);
}
