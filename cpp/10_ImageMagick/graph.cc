// Jessie Runnoe and Erin Stuhlsatz
// May 2007
// Assignment 10: Image Magick

#include <Magick++.h>
#include <iostream>
#include <list>
#include <math.h>

using namespace std;
using namespace Magick;

#include "graph.h"

template class list<Coordinate>;

  // Constructor specifies the initial image size and color.
graph::graph(): Image ("500x500", "white") {
}

  // Computes an array of points that satisfy f(x) = sin (x).
double graph::sine ( double start, double end ) {
  int i;
  
  inc = ( end - start )/ (ELEMENTS-1);

  x[0] = start;
  fx[0] = sin (x[0]);
  
  for ( i = 1; i <= ELEMENTS; i++ ) {
	x[i] = x[i-1] + inc;
	fx[i] = sin (x[i]);
  }

}

  // Computes an array of points that satisfy f(x) = cos (x).
double graph::cosine ( double start, double end ) {
  int i;

  inc = ( end - start )/ (ELEMENTS-1);

  x[0] = start;
  fx[0] = cos (x[0]);
  
  for ( i = 1; i <= ELEMENTS; i++ ) {
	x[i] = x[i-1] + inc;
	fx[i]= cos(x[i]);
  }
}


  // Converts 'x' coordinate to a horizontal pixel coordinate.
int graph::xtoh () {
  int i;
  for ( i = 0; i <= ELEMENTS; i++ ) {
	h[i] = 50 + (4.0/5.0)*(i);			// Gives a 50 pixel border and a range of 400 pixels.
  }
}

  // Converts 'y' coodinate to a vertical pixel coordinate.
int graph::ytov () {
  int i;
  for ( i = 0; i <= ELEMENTS; i++ ) {
	v[i] = 250 - 200*(fx[i]);			// Centers vertically at 250 pixels with a 200 pixel range on either side.
  }
}

  // Plots the sine curve.
void graph::graph_sine () {
  int i;
  
  cout << "Please wait a moment while the sine plot is computed." << endl;
  
  xtoh();
  ytov();
  axes();
  strokeColor("black");
  for ( i = 1; i <= ELEMENTS - 2; i++ ) {
	draw(DrawableLine( h[i], v[i], h[i+1], v[i+1] ));
  }
}

  // Plots the cosine curve.
void graph::graph_cosine () {
  int i;

  xtoh();
  ytov();
  axes();
  
  cout << "Please wait a moment while the cosine plot is computed." << endl;
  strokeColor("black");
  for ( i = 1; i <= ELEMENTS - 2; i++ ) {
	draw(DrawableLine ( h[i], v[i], h[i+1], v[i+1] ));
  }
}

  // Plots the axes.
void graph::axes () {
  //draw(DrawableLine (50, 50, 50, 450));		// The vertical axis is not necessarily at zero.
  draw(DrawableLine (50, 250, 450, 250));
}
