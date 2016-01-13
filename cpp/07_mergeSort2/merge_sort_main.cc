// Matt Pearson & Jessie Runnoe
// Assignment 7

// Read in two data files, print
// their contents to the screen,
// merge them and sort them and
// print these to the screen, too.

#include <fstream>
#include <iostream>
#include "merge_class.h"
#define FILENAME_LENGTH 1024

using namespace std;
string garbage;

data_set rhs, lhs;
int v;

// Overloading "+" operator
data_set operator + (const data_set & lhs, const data_set & rhs) {
	data_set temp;
	temp = lhs;
	temp += rhs;
	return (temp);
}
// Overloading "cout"
ostream & operator << (ostream & ostr, data_set & rhs) {
	int i;
	for (i=0; rhs.get_item( i, v ); i++) {
		ostr << v << " ";
	}
	return (ostr);
}
// Overloading "cin"
istream & operator >> (istream & istr, data_set & d) {
	int i;
	while (istr >> i) {
		rhs.add_item(i);
	}
	//istream.clear();
	return (istr);
}

main () {

  int dat,j, capacity, t, pos, term;
  char filename[FILENAME_LENGTH];
  data_set D;
  ifstream datafile;

  cerr << "Data file? ";
  cin >> filename;
  datafile.open(filename);
  while (datafile >> dat) {
	D.add_item (dat);
  }
  datafile.close();

  char opt;
  while (opt != 'q' || opt != 'Q') {
	// Display list of available options
	cout << endl << "Options: " << endl
		<< "[t] Search for a term" << endl
		<< "[q] Quit this program" << endl
		<< endl
		<< "Choose an option: ";

	cin >> opt;

	switch (opt) {
		case 't':
		case 'T':
			// Sort array and search for inputted term
	  		D.sort();
			cerr << "Choose a number: ";
			while (cin >> term) {
				pos = D.find(term);
				if (pos >= 0 ) {
					cout << "Term " << term << " is in position " << pos << endl;
				}
				else { 
					cerr << " Term Not Found " << endl; 
				}
				cerr << "Choose a number: ";
			}	
			cin.clear();
			getline (cin, garbage);
			break;
		case 'a':
		case 'A':
			// Add a term to the array
			break;
		case 'q':
		case 'Q':
			return 0;
	}
  }	
}
