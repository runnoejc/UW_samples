// Matt Pearson & Jessie Runnoe
// Assignment 6
#include <iostream>
#include <stdlib.h>
#include <sys/times.h>
using namespace std;

// Designed to be used to write a list
// of random integers into a file

main (int argc, char** argv) {
  struct tms dummy;
  srand48(times(&dummy));
  int n,m;
  cerr << "How many ints? ";
  cin >> n;
  cerr << "Maximum value? ";
  cin >> m;
  for (int i=1; i<=n; i++) {
    cout << (int)(drand48()*(m+1)) << endl;
  }    
}
