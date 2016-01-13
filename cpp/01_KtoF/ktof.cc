// Jessie Runnoe
// Assignment 1:  Kelvins to degrees Fahrenheit


#include <iostream>
using namespace std;




void prompt ()				//Function prompt() to prompt user to input temperature.
{
  cout << "To convert from kelvins to degrees Fahrenheit, please enter a temperature and press enter:  ";  
}


double ktof (double k)		//Function ktof(k) to convert kelvins to degrees Fahrenheit.
{
  double f=(9.0/5)*(k-273.15)+32;
  return(f);
}


void display (double f, double k)		//Function display() to display result of conversion to user.
{
  cout << k << "K = " << f << " degrees Fahrenheit.";
}




main()
{	
  double k,f;			//Defines variables as decimals.
  
  cout << "\n\n";
  
  prompt ();			//Calls function prompt().
  cin >> k;				//Takes temperature input.
  f=ktof (k);			//Calls function ktof(k).
  display (f,k);		//Calls function display().

  cout << "\n\n";
}
