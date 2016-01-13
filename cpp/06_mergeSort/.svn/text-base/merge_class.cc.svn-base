// Matt Pearson & Jessie Runnoe
// Assignment 6
#include <iostream>
#include "merge_class.h"
using namespace std;

data_set::data_set () {
	// Default constructor
	num_items = 0;
	capacity = 100;
	aux = new int [capacity];
	D = new int [capacity];
	prev_term = 0;
	prev_index = 0;
}

data_set::~data_set () {
	// Default destructor
	delete []aux;
	delete []D;
}

void data_set::merge ( int l, int r ) {
  // Merges array segments together
  int i,lp,rp;
  i = l;
  lp = l;
  rp = (l+r)/2+1;

  while ( lp <= (l+r)/2 && rp <= r) {
    if (D[lp] < D[rp]) {
      aux[i++] = D[lp++];
    } else {
      aux[i++] = D[rp++];
    }
  }

  while ( lp <= (r+l)/2 ) {
      aux[i++] = D[lp++];
  }
  while ( rp <= r ) {
    aux[i++] = D[rp++];
  }
  for (i = l; i <= r; i++ ) {
    D[i] = aux[i];
  }
}

void data_set::mergesort( int l, int r) {
	// Sorts array segments and calls merge function to merge them back together 
	if (l < r) {
    	mergesort(l, (l+r)/2);
    	mergesort((l+r)/2+1, r);
    	merge(l, r);
  	}
}

void data_set::add_data_item ( int dat ) {
	// Adds data from file to array D
	int i, j, *temp;
	// Increases capacity of array D by factor of 2
	if (num_items == capacity) {
		temp = new int [capacity*2];
	   	for ( i = 0; i < capacity; i++ ) {
			temp [i] = D [i];
	   	}
	   	delete []D;
	  	D = temp;
	   	capacity *= 2;
	}
	// Adds each data item to array D from file
	// Updates num_items
	D [num_items] = dat;
	num_items = num_items + 1;
}


void data_set::sort () {
	// Calls mergesort function to sort data in array
	mergesort (0, num_items-1);
}

int data_set::find ( int term ) {
	// Locates specific data item in array
 	int i;
	int start_index;

	// Start searching from current index if new
	// term is larger than previously-searched term
	if (term < prev_term) {
		start_index = 0;
	} else {
		start_index = prev_index;
	}

	for (i=start_index; i<=capacity; i++) {
		if (D[i]==term) {
			prev_index = i;
			prev_term = term;
			return i;
		}
	}	
	return (NOT_FOUND);
}

// Getters
int data_set::get_data_item ( int t ) { return D[t]; }

