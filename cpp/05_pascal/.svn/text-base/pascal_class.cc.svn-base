// Matt Pearson & Jessie Runnoe
// Assignment 5: Pascal's Triangle
// pascal_CLASS functions

#include "pascal_class.h"
#include <iostream>
#include <iomanip>
using namespace std;

pascal::pascal () {
	// Default constructor
	int i;
	row = 0;
	A[0] = 1;
	A[1] = 0;
	B[0] = 0;
	B[1] = 0;
	// Initializes array elements to zero
	for (i=2; i<=99; i++) {
		A[i] = 0;
		B[i] = 0;
	}
	debug = false;
}

void pascal::reset () {
	// Start at the beginning of the triangle
	int i;
	row = 0;
	A[0] = 1;
	B[0] = 0;

	// Initializes array
	// all elements = 0
	for (i=1; i<=99; i++) {
		A[i] = 0;
		B[i] = 0;
	}
}

// Generates an array containing all terms of a given row
int pascal::compute_row (int r, int t, bool debug) {
	int i, j, k;

	// Verifies that compute_row has received the correct row and term numbers
	if (debug) {cout << endl << "You asked for row " << r << endl;}
	if (debug) {cout << "You asked for term number " << t << "\n\n";}
	
	// Computes rows of Pascal's Triangle
	for (i=row; i<=r; i++) {
		for (j=0; j<=i; j++) {
			if( j==0 ) {
            B[j] = A[j];
         }
         if( j > 0 ) {
            B[j] = A[j] + A[j-1];
         }
			if (debug) {cout << setw(4) << B[j];}		// Prints triangle if debug is on
		}
			for (k=0; k<=r+1; k++) {						// Copies array B into array A
		  		A[k] = B[k];
			}
		if (debug) { cout << endl; }					// Separates rows of triangle if debug is on
		row = i;
	}	
}

// Getters
int pascal::get_term (int t) { return B[t]; }
int pascal::get_row () { return row;}

