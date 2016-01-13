//Jessie Runnoe
//Assignment 2: Multiplication Table

//Takes user input n and prints an
//nxn multiplication table.

#include <iostream>
#include <iomanip>

using namespace std;



int input_n (int n)		//Function prompts user to input an integer n and conditionally takes input n.		
{ 
  cout << "To display an nxn multiplication table please enter a positive integer value for n: ";
  cin >> n;

  if (n>0)				//This disallows a negative value for n and prompts the user for a positive, non zero n value.
  {	
	return n;
  }
  else
  {
	cout << "\n\n";
	cout << "You entered n=" << n << ", please choose a positive, non zero value for n:  ";
	cin >> n;

	if (n>0)			//This disallows a second negative value for n.  I wanted to write this so that it would continue prompting you to enter a positive n, but I'm not sure how. 
	{
	  return n;
	}
	else
	{
	  cout << "\n\n";
	  cout << "Please look up the definition of a negative number and run the program again.";		//My sarcastic method of ending the program nicely rather than crashing it.
	}
  }
}




int display_table (int i, int j, int n, int k)			//Function displays nxn table.
{
  if (n<10)					//Sets column width for n<10 and n>=10.
	k=3;
  else
	k=4;
  for (i=1; i<n+1; i=i+1) 
  {
	for (j=1; j<n+1; j=j+1) 
	{ 
	  cout << setw(k) << i*j; 
	}
	cout << endl;
  }
}




main ()
{
  int i;
  int j;
  int n;
  int k;
  
  cout << "\n\n";
  
  n = input_n (n);

  cout << "\n\n";

  display_table (i,j,n,k); 
  
  cout << "\n\n";
}





