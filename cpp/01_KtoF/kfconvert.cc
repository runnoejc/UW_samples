// Jessie Runnoe
// Assignment 1a:  Likey Likey


#include <iostream>
using namespace std;




double ktof (double k)
{
  double f=(9.0/5)*(k-273.15)+32;
  return(f);
}



double ftok (double f) 
{
  double k=5*(f-32)/9+273.15;
  return(k);
}






 
main() {
	
  double t,k,f;		//Defines variables as decimals.
  char ch = 5;		//Defines characters somehow.  I need to figure out how to define character strings.

cout << "Please enter a temperature (use K to denote kelvins and F to denote degrees fahrenheit):  ";		//Displays prompt to user.
cin >> t;		//Takes temperature input.
cin >> ch;		//Takes character input to specify units.


switch (ch) {		//Allows switch between kelvins and degrees Fahrenheit.
  case 'K':		//Begins calculation for temperatures entered in kelvins. 
  k=t;		//Designates entered temperature as variable k.  
  f=ktof (k);		//Runs function ktof(k) which converts kelvins to degrees Fahrenheit.		
  cout << k << "K = " << f << " degrees fahrenheit.";		//Displays the result to user.
  break;		//Ends case 'k'.
  
  case 'F':		//Begins calculation for temperatures entered in degrees Fahrenheit.  
  f=t;
  k=ftok (f);
  cout << f <<" degrees fahrenheit = " << k << " kelvins.";
  break;
}

cout << endl;		//Outputs a new line.
	
}
