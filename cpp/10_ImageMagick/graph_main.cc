// Jessie Runnoe and Erin Stuhlsatz
// May 2007
// Assignment 10: Image Magick

// Plot sine and cosine curves given
// user inputs for the x range.

#include <Magick++.h>
#include <iostream>
#include <math.h>

using namespace std;
using namespace Magick;

#include "graph.h"


int main () {
  double start, end;
  graph G;
  char command;
  
  cout << endl << "To display the help menu, press 'h'" << endl << endl;
  
  while ( command != 'q' ) {
	cout << "|-->  ";
	cin >> command;

	switch (command) {
	  case 'h':
		// Display the help menu.
		cout << endl << " -Available Commands- " << endl << endl
		  << " h -- Shows this screen." << endl
		  << " s -- Displays a sine curve." << endl
		  << " c -- Displays a cosine curve." << endl
		  << " b -- Displays the sine and cosine curves." << endl
		  << " m -- Displays m sine curves." << endl
		  << " n -- Displays n cosine curves." << endl
		  << " q -- Quits the program." << endl
		  << endl;
		
		break;

	  case 's':
		// Plot sine.
		
		cout << "Please enter a minimum x value: ";
		cin >> start;
		cout << "Please enter a maximum x value: ";
		cin >> end;

		G.sine (start, end);  
		G.graph_sine ();
		G.display ();
		G.erase ();
		break;

	  case 'c':
		// Plot cosine.
	
		cout << "Please enter a minimum x value: ";
		cin >> start;
		cout << "Please enter a maximum x value: ";
		cin >> end;

		G.cosine (start, end);  
		G.graph_cosine ();
		G.display ();	
		G.erase ();
		break;

	  case 'b':
		// Plot sine and cosine together.
		
		cout << "Please enter a minimum x value: ";
		cin >> start;
		cout << "Please enter a maximum x value: ";
		cin >> end;

		G.cosine (start, end);  
		G.graph_cosine ();
		G.sine (start, end);
		G.graph_sine ();
		G.display ();
		G.erase ();
		break;

	  case 'm':
		// Sort of a weird option where you can plot sine curves together for different ranges of x.
		int i, m;
		cout << "Please specify how many sine curves you would like to plot: ";
		cin >> m;
		
		for ( i = 0; i < m; i++ ) {
		  cout << "Please enter a minimum x value: ";
		  cin >> start;
		  cout << "Please enter a maximum x value: ";
		  cin >> end;
		  
		  G.sine (start, end);
		  G.graph_sine ();
		}
		G.display ();
		G.erase ();
		break;

	  case 'n':
		// Weird option for cosine.
		int j, n;
		cout << "Please specify how many sine curves you would like to plot: ";
		cin >> n;
		
		for ( j = 0; j < n; j++ ) {
		  cout << "Please enter a minimum x value: ";
		  cin >> start;
		  cout << "Please enter a maximum x value: ";
		  cin >> end;
		  
		  G.cosine (start, end);
		  G.graph_cosine ();
		}
		G.display ();
		G.erase ();
		break;
		
	  case 'q':
		cout << "Make good choices!" << endl;
		break;

	  default:
		cout << "The command you entered is invalid." << endl;
		break;

	}
  }
}
