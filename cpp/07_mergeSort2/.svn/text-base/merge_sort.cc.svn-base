// Matt Pearson & Jessie Runnoe
// Assignment 7
#define DEBUG true
#define FILENAME_LENGTH 256
using namespace std;
#include <fstream>
#include <iostream>
#include "merge_class.h"

// Notice that all output is to cerr except the final output of the
// sorted data. This means you can use "merge_sort > sorted" to put
// the sorted data into a file called "sorted".

void save_data(data_set X) {
  cout << X << endl;
}

main () {
  int dat,j;
  char filename[FILENAME_LENGTH];
  data_set D,E,F;
  ifstream datafile;

  cerr << "First data file? ";
  cin >> filename;
  
  datafile.open(filename);
  
  datafile >> E;
 
  datafile.close();

  cerr << "Second data file? ";
  cin >> filename;

  datafile.open(filename);

  while (datafile >> dat) {
    F.add_item(dat);
  }

  datafile.close();


  if ( DEBUG ) {
    cerr << "Data set 1: " << endl;
    cerr << E << endl;
    cerr << "Data set 2: " << endl;
    cerr << F << endl;
  }

  D=E+F;

  if ( DEBUG ) {
    cerr << "Combined data set:" << endl;
    cerr << D << endl;
  }
  
  D.sort();

  save_data(D);
}
