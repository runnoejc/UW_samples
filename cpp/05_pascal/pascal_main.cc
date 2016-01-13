// Matt Pearson & Jessie Runnoe
// Assignment 5: Pascal's Triangle
// MAIN.cc

// Calculate a pascal's triangle 
// and allow the user to explore it.

#include "pascal_class.h"
#include <iostream>
using namespace std;

// Global Debug Variable & Function
// Debug variable will also need to be passed (as necessary) to class member functions
bool debug = false;
void set_debug() {
	if (debug == false) {
			debug = true;
	} else {
			debug = false;
	}	
}

// Generate and query a Pascal Triangle
void query_pascal ( int r ) {
	
	pascal P;
	char opt;
	int n, t;
	string garbage;

	cout << "Enter a term number for row " << r << " ('q' to quit): ";
	while (cin >> t) {
		if (r < P.get_row()) {
			P.reset();
			P.compute_row(r, t, debug);	
		} else if (r > P.get_row()) { P.compute_row(r, t, debug);}
		cout << endl << " " << P.get_term( t ) << endl << endl;
		cout << "Enter a term number for row " << r << " ('q' to quit): ";
	}
	// Clear input to prevent menu from endlessly looping
	cin.clear();
	getline (cin, garbage);
	return;
}


// Print Main Menu
void main_menu () {
	char opt;

	while (opt != 'q' || opt != 'Q') {

		// Display list of available options
		cout << endl << "Options: " << endl
			<< "[r] Choose a row and term" << endl
	     	<< "[d] Toggle debug mode" << endl
			<< "[q] Quit this program" << endl
			<< endl
			<< "Choose an option: ";

		cin >> opt;
	
		switch(opt) {
			case 'r':
			case 'R':
				if (debug) {cout << "You chose [R]." << endl;}
				cout << "Enter a row number: ";
				int r;
				cin >> r;
				query_pascal(r);
				break;
			case 'd':
			case 'D':
				if (debug) {cout << "You chose [D]." << endl;}
				set_debug();
				cout << "Debug mode has been set to " << debug << endl;
				break;
			case 'q':
			case 'Q':
				if (debug) {cout << "You chose [Q]." << endl;}
				cout << "Program has ended." << endl;
				return;
				break;
			default:
				cout << "You chose an invalid option.  Please try again." << endl << endl;
				break;
		}
	}
}

main () {
	main_menu();
}
