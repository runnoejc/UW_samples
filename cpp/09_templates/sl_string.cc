// Jessie Runnoe
// Assignment 9

// This is the file that creates a version of the data_set class to
// hold official C++ strings ("standard library" strings).

#include <iostream>
#include <string>
using namespace std;
//#include "merge_class.h"
#include "merge_class.cc"

template class data_set<string>;

template
ostream& operator<<(ostream& ostr, data_set<string> & d);

template
istream& operator>>(istream& istr, data_set<string> & d);

template
data_set<string> operator+(const data_set<string>& lhs, 
			   const data_set<string>& rhs);
