// Jessie Runnoe
// Assignment 9
#include <iostream>
using namespace std;
#include "merge_class.h"

template <class dsbt>
data_set<dsbt>::data_set () {
	// Default constructor
	num_items = 0;
	capacity = DEFAULT_CAPACITY;
	aux = new dsbt [capacity];
	D = new dsbt [capacity];
	//prev_term = 0;
	prev_index = 0;
}

template <class dsbt>
data_set<dsbt>::data_set (const data_set<dsbt> & rhs){
  // Copy Constructor
  D = 0;
  aux = 0;
  (*this) = rhs;
}

template <class dsbt>
data_set<dsbt>::~data_set () {
	// Default destructor
	delete []aux;
	delete []D;
}

template <class dsbt>
void data_set<dsbt>::merge ( int l, int r ) {
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

template <class dsbt>
void data_set<dsbt>::mergesort( int l, int r) {
	// Sorts array segments and calls merge function to merge them back together 
	if (l < r) {
    	mergesort(l, (l+r)/2);
    	mergesort((l+r)/2+1, r);
    	merge(l, r);
  	}
}

template <class dsbt>
void data_set<dsbt>::add_item ( dsbt dat ) {
	// Adds data from file to array D
	int i, j;
	dsbt *temp;
	// Increases capacity of array D by factor of 2
	if (num_items == capacity) {
		temp = new dsbt [capacity*2];
	   	for ( i = 0; i < capacity; i++ ) {
			temp [i] = D [i];
	   	}
	   	delete []D;
	  	D = temp;
	   	capacity *= 2;
		delete [] aux;
		aux = new dsbt [capacity];
	}
	// Adds each data item to array D from file
	// Updates num_items
	D [num_items] = dat;
	num_items = num_items + 1;
}

template <class dsbt>  
void data_set<dsbt>::sort () {
	// Calls mergesort function to sort data in array
	mergesort (0, num_items-1);
}

template <class dsbt>
int data_set<dsbt>::find ( dsbt term ) {
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

	for (i=start_index; i<num_items; i++) {
		if (term < D[i]) break;
		if (D[i]==term) {
			prev_index = i;
			prev_term = term;
			return i;
		}
	}	
	return (NOT_FOUND);
}

// Overloading "+=" operator
template <class dsbt>
data_set<dsbt> & data_set<dsbt> :: operator += ( const data_set<dsbt> & rhs ) {
	for (int i=0; i < rhs.num_items; i++) { add_item (rhs.D[i]); }
	return (*this);
	cerr << " += Overloaded" << endl;
}

// Overloading "=" operator
template <class dsbt>
data_set<dsbt> & data_set<dsbt> :: operator = (const data_set<dsbt> & rhs) {
  int i;
  if (this != & rhs) {
	delete [] D;
	capacity = rhs.capacity;
	num_items = rhs.num_items;
	D = new dsbt [capacity];
	for (i = 0; i < num_items; i++) {
	  D[i] = rhs.D[i];
	}
	//delete [] rhs.D;
	delete [] aux;
	aux = new dsbt [capacity];
  }
  return (*this);
}

// Overloading "+" operator
template <class dsbt>
data_set<dsbt> operator + (const data_set<dsbt> & lhs, const data_set<dsbt> & rhs) {
  data_set<dsbt> temp;
  temp = lhs;
  temp += rhs;
  return (temp);
}

// Overloading "cin"
template <class dsbt>
istream & operator >> (istream & istr, data_set<dsbt> & rhs) {
  dsbt i;
  while (istr >> i) {
	rhs.add_item (i);
  }
  istr.clear();
  return (istr);
}

// Overloading "cout"
template <class dsbt>
ostream & operator << (ostream & ostr, data_set<dsbt> & rhs) {
  int i;
  dsbt v;
  for ( i=0; rhs.get_item ( i, v ); i++ ) {
	ostr << v << " " ;
  }
  return (ostr);
}

// Printers and Getters
template <class dsbt>
void data_set<dsbt>::get_array () { 
  int i;
  for ( i = 0; num_items; i++) {
//	return D[i];
	cerr << D[i];
  }
}
template <class dsbt>
dsbt data_set<dsbt>::get_data_item ( int t ) { return D[t]; }

template <class dsbt>
int data_set<dsbt>::get_item (int i, dsbt & v) {
  if ( i >= 0 && i<num_items ) {
    v = get_data_item ( i );
	return ( 1 );
  }
  return ( 0 );
}
