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

  int while_i = 0;


  Rcout << "lo is " << lo << "\n";

  Rcout << "hi is " << hi << "\n";

  Rcout << "n_txns is " << n_txns << "\n";

  Rcout << "n_txns minus 1 is " << n_txns - 1 << "\n";

  Rcout << "n_cards is " << n_cards << "\n";



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

  Rcout << "Past 1st if else block" << "\n";

  Rcout << "Ntxns minus 1 "  << n_txns - 1 << "\n";

  //Rcout << "range test: " << Rcpp::Range(0, n_txns - 1).get_start() << Rcpp::Range(0, n_txns - 1).get_end() << "\n";

  int n_txn_m1 = n_txns - 1;

  Rcout << "Unique N Check: " << unique_n(cards[Range(0, 33)]) << "\n";

  Rcout << "range Check: " << Range(0, n_txn_m1).get_end() << "\n";

  CharacterVector cards_end_m1 = cards[Range(0, n_txn_m1)];

  //Rcout << "Cards m1 length check : " << cards_m1.length() << "\n";

  //Rcout << "Cards m1 Uniquen check: " << unique_n(cards_m1) << "\n";

  // check if max date is last date in data set
  if(unique_n(cards_end_m1) == n_cards - 1){

    opt_dates.push_back(dates[n_txns]);
      
    cards_sub = cards;
    dates_sub = dates;

    Rcout << "End Date Value is " << dates[n_txns] << "\n";


  } else {

    while (lo <= hi){

      Rcout << "in while loop \n";

      while_i++;

      // integer division returns quotient in c++
      mid = lo + (hi - lo) / 2;

      Rcout << "Mid Value " << while_i << " is " << mid << "\n";

      cards_loop = cards[Range(0, mid)];
      cards_loop_next = cards[Range(0, (mid - 1))];

      if ( unique_n(cards_loop) == n_cards  &&
           unique_n(cards_loop_next) == n_cards - 1){

        opt_dates.push_back(dates[mid]);

        Rcout << "End Date Value is " << dates[mid] << "\n";



        // subset data for next loop iteration
        cards_sub = cards_loop;
        dates_sub = dates[Range(0, mid)];

        break;

      } else if (unique_n(cards_loop) < n_cards){

        lo = mid + 1;

        Rcout << "New Low Value " << while_i << " is " << lo << "\n";

      } else {

        hi = mid - 1;

        Rcout << "New Hi Value " << while_i << " is " << hi << "\n";
      }

    }

  }
  

  Rcout << "Past End Point Search if else block" << "\n";

  // last index for full subset of data
  n_txns = cards_sub.length() - 1;

  lo = 0;
  hi = n_txns;
  
  Rcout << "lo is " << lo << "\n";
  
  Rcout << "hi is " << hi << "\n";
  
  Rcout << "n_txns is " << n_txns << "\n";
  
  CharacterVector cards_start_m1 = cards[Range(1, n_txns)];
  
  while_i = 0;

  // check if min date is first date in data set
  if(unique_n(cards_start_m1) == n_cards - 1){

    opt_dates.push_front(dates_sub[0]);

    return(opt_dates);

  } else {

    while(lo <= hi){
        
      while_i++;
        
      Rcout << "in 2nd while loop \n";

      // integer division returns quotient in c++
      mid = lo + (hi- lo) / 2;
      
      Rcout << "Mid Value " << while_i << " is " << mid << "\n";

      // search subsets for checking n cards
      cards_loop = cards_sub[Range(mid, n_txns)];
      cards_loop_next = cards_sub[Range((mid + 1) , n_txns)];
      
      Rcout << "Cards_loop Length" << cards_loop.length() << "\n";
      
      Rcout << "cards_loop_next length " << cards_loop_next.length() << "\n";
      
      Rcout << "uniquen cards loop " << unique_n(cards_loop) << "\n";
      
      Rcout << "uniquen cards loop next " << unique_n(cards_loop_next) << "\n";
      
      Rcout << "Made it past subsetting \n";

      if (  unique_n(cards_loop) == n_cards  &&
            unique_n(cards_loop_next) == n_cards - 1){

        opt_dates.push_front(dates_sub[mid]);

        return(opt_dates);

      } else if ( unique_n(cards_loop) < n_cards){

        hi = mid + 1;
         
        Rcout << "New Hi Value " << while_i << " is " << hi << "\n";
          
      } else {

        lo = mid - 1;
          
        Rcout << "New Low Value " << while_i << " is " << lo << "\n";
      }
    }

  }// end else

  return(opt_dates);
}
