// Matt Pearson & Jessie Runnoe
// Assignment 4

// Computes and displays a Lucas Sequence 

#include <iostream>
using namespace std;

class lucas {
	private:
		int a_0, a_1, current, previous, term_num;
	public:
		lucas();
		lucas (int, int);
		void initialize (int, int);
		void reset();
		int next();
		int term (int);

		int get_a0();
		int get_a1();
		int get_current();
		int get_previous();
		int get_termNum();
};


// ---- Lucas Class Functions ---- //

// Default Constructor
lucas::lucas() {
	a_0 = 0;
	a_1 = 1;
	term_num = 0;
	current = a_0;
	previous = a_1 - a_0;
}

// New Sequence Initializers
lucas::lucas (int m, int n) {
	a_0 = m;
	a_1 = n;
	term_num = 0;
}
void lucas::initialize (int m, int n) {
	a_0 = m;
	a_1 = n;
	term_num = 0;
}

// Getters
int lucas::get_a0() { return a_0; }
int lucas::get_a1() { return a_1; }
int lucas::get_current() { return current; }
int lucas::get_previous() { return previous; }
int lucas::get_termNum() { return term_num; }


// Reset current & previous to correct starting values
void lucas::reset() {
	current = a_0;
	previous = a_1 - a_0;
	term_num = 0;
}

// Compute the next term, set current, previous and term_num
int lucas::next() {
	int next;
	next = previous + current;
	previous = current;
	current = next;
	term_num=term_num + 1;
}

// Compute term given by parameter, set current, previous, term_num
int lucas::term (int index) {
	int i, next;
	if ( index < term_num ) { reset(); }
	for ( i=term_num; i<index; i++ ) {
	  next = previous + current;
	  previous = current;
	  current = next;
	  term_num = i;
	}
}


// ---- User Interface ---- //

// Print list of options and takes user input of option choice
void choose_option() {

	lucas L;

	char opt;

	// Program continues until Q or q is input
	while (opt != 'q' || opt != 'Q') {	 
	 
		cout << endl << "Options:" << endl
			<< "[n] Define a new sequence" << endl
			<< "[t] Show a specific term from the current sequence" << endl
			<< "[a] Show all terms in the current sequence" << endl
			<< "[q] Quit this program" << endl
			<< endl
			<< "Choose an Option: ";

		cin >> opt;

		switch(opt) {
			case 'n':
			case 'N':
				int m, n;
				cout << "Enter two integers to define a new Lucas Sequence: ";
				cin >> m >> n;
				L.initialize(m, n);
			 	break;
			case 't':
			case 'T':
				int t_index;
				cout << "Enter the term number you wish to see: ";
				cin >> t_index;
				L.term(t_index);
				cout << " " << L.get_current() << endl;
				break;
			case 'a':
			case 'A':
				
				int a_index, i;
				
				cout << "Enter the last term number you wish to see: "; cin >> a_index;
				
				L.reset();
				for (i=0; i<=a_index; i++){ 
				  cout << " " << L.get_current() << " ";
				  L.next(); 
				}
				cout << endl;
				break;
			case 'q':
			case 'Q':
				cout << "Thank you for using our nifty Lucas Sequence program!  Have a fantabulous day!" << endl;
				return;
				break;
			default:
				cout << "You chose an invalid option.  Please try again." << endl << endl;
		 		break;
		}	// End Switch(opt)

	}	// End loop

}	// End chose_option()


main() {

	choose_option();
	cout << endl << endl;

}
