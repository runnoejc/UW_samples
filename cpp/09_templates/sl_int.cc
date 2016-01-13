// This is the file that creates a version of the data_set class to
// hold official C++ strings ("standard library" strings).

#include <iostream>
using namespace std;
//#include "merge_class.h"
#include "merge_class.cc"

template class data_set<int>;

template
ostream& operator<<(ostream& ostr, data_set<int> & d);

template
istream& operator>>(istream& istr, data_set<int> & d);

template
data_set<int> operator+(const data_set<int>& lhs, 
			   const data_set<int>& rhs);
