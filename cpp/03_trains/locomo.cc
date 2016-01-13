//Jessie Runnoe
//Assignment 3:  Railcars

//Calculate volumes of specific
//types of train cars given user
//inputs for the dimensions.

#include <iostream>
#include <iomanip>

using namespace std;

//Global Variables
const double pi=3.14159265358979323846;


//Begin Test Functions

  //Tests dimensions for box car.  If all dimensions are between zero and ten meters, it returns "true", otherwise it resturns "false".
bool test_box (double l, double w, double h)
{
  if (l>=0 && l<10 && w>=0 && w<10 && h>=0 && h<10)
  {
	return (true);
  }
  else 
  {
	return false;
  }
}

  //Tests dimensions for tank car. If all dimensions are between zero and ten meters, it returns "true", otherwise it resturns "false".
bool test_tank (double l, double r)
{
  if (l>=0 && l<10 && r>=0 && r<10)
  {
	return (true);
  }
  else
  {
	return (false);
  }
}

  //Tests dimensions for flat car.  If all dimensions are between zero and ten meters, it returns "true", otherwise it resturns "false".
bool test_flat (double l, double w)
{
  if (l>=0 && l<10 && w>=0 && w<10)
  {
	return (true);
  }
  else
  {
	return (false);
  }
}
//End Test Functions


//Begin Boxcar

class boxcar
{
  private: 
	double length, width, height;
  public:
	  double get_length ();
	  void set_length (double l);
	  double get_width ();
	  void set_width (double w);
	  double get_height ();
	  void set_height (double h);
	  double volume (double v);
	  boxcar();
};

boxcar::boxcar()
{
  length=6;
  width=4;
  height=4;
}

double boxcar::get_length ()
{
  return (length);  
}


void boxcar::set_length (double l)
{
  length=l;
}


double boxcar::get_width ()
{
  return (width);
}


void boxcar::set_width (double w)
{
  width=w;
}


double boxcar::get_height ()
{
  return (height);
}


void boxcar::set_height (double h)
{
  height=h;
}


double boxcar::volume (double v)
{ 
  v=length*width*height;
 return (v);
}

//End Boxcar


//Begin Display Boxcar

void input_boxcar (double l, double w, double h, double v)
{
  boxcar B;
  
  //Displays default dimensions and takes new dimensions.
  cout << "The default box car has dimensions " << B.get_length() << " x " << B.get_width() << " x " << B.get_height() << " and volume " << B.volume(v) << " cubic meters." << endl;
  cout << "To calculate the volume of a specific box car, please specify values for the length, width, and height of the car that are between zero and ten meters: ";
  cin >> l >> w >> h;
  
  //Calls function to test validity of new dimensions.  If they're invalid it quits the boxcar section of the program and returns to main, otherwise it sets them.
  bool ok;
  ok=test_box(l, w, h);		//Gets either "true" or "false" from test function and puts it into "ok".
  if (!ok)					//If it received "false", it gives the error message.
  {
	cout << "The dimensions you specified were invalid.  The volume of this car cannot be calculated.";
	cout << "\n\n";
	return;
  }
  else						//If it received "true", it sets the dimensions.
  {
	B.set_length(l);
	B.set_width(w);
	B.set_height(h);
  }
  
  //Displays volume calculated with new dimensions.
  cout << "This box car has a volume of " << B.volume(v) << " cubic meters";
  cout << "\n\n";
}

//End Display Boxcar


//Begin Tank Car
class tankcar
{
  private: 
	double length, radius;
  public:
	  double get_length ();
	  void set_length (double l);
	  double get_radius ();
	  void set_radius (double r);
	  double volume (double v);
	  tankcar();
};

tankcar::tankcar ()
{
  length=6;
  radius=3;
}

double tankcar::get_length ()
{
  return (length);
}

void tankcar::set_length (double l)
{
  length=l;
}


double tankcar::get_radius ()
{
  return (radius);
}

void tankcar::set_radius (double r)
{
  radius=r;
}

double tankcar::volume (double v)
{
  v=length*pi*radius*radius;
  return (v);
}
//End Tank Car


//Begin Display Tankcar

void input_tankcar (double l, double r, double v)
{
  tankcar T;
  
  //Displays default dimensions and takes new dimensions.
  cout << "The default tank car has length " << T.get_length() << " and radius " << T.get_radius() << " and a volume of " << T.volume(v) << " cubic meters." << endl;
  cout << "To calculate the volume of a specific tank car, please specify values for the length and radius of the car that are between zero and ten meters: ";
  cin >> l >> r;
  
  //Calls function to test validity of new dimensions.  If they're invalid it quits the boxcar section of the program and returns to main, otherwise it sets them. 
  bool ok;
  ok=test_tank(l, r);		//Gets either "true" or "false" from the test function and puts it into "ok".
  if (!ok)					//If it received "false", it gives the error message.
  {
	cout << "The dimensions you specified were invalid.  The volume of this car cannot be calculated.";
	cout << "\n\n";
	return;
  }
  else						//If it received "true", it sets the dimensions.
  {
	T.set_length(l);
	T.set_radius(r);
  }
  
 
  //Displays volume calculated with new dimensions.  
  cout << "This tank car has a volume of " << T.volume(v) << " cubic meters";
  cout << "\n\n";
}
//End Display Boxcar


//Begin Flatcar

class flatcar
{
  private: 
	double length, width, height;
  public:
	  double get_length ();
	  void set_length (double l);
	  double get_width ();
	  void set_width (double w);
	  double get_height ();
	  double volume (double v);
	  flatcar();
};

flatcar::flatcar()
{
  length=10;
  width=10;
  height=10;
}

double flatcar::get_length ()
{
  return (length);  
}


void flatcar::set_length (double l)
{
  length=l;
}


double flatcar::get_width ()
{
  return (width);
}


void flatcar::set_width (double w)
{
  width=w;
}


double flatcar::get_height ()
{
  return (height);
}


double flatcar::volume (double v)
{ 
  v=length*width*height;
  return (v);
}
//End Flatcar


//Begin Display Flatcar

void input_flatcar (double l, double w, double h, double v)
{
  flatcar F;
 
  //Displays default dimensions and takes new dimensions.
  cout << "The default volume has dimensions " << F.get_length() << " x " << F.get_width() << " x " << F.get_height() << " and volume " << F.volume(v) << " cubic meters." << endl;
  cout << "To calculate the volume of a specific flat car, please specify values for the length and width of the car that are between zero and ten meters: ";
  cin >> l >> w;

  //Calls function to test validity of new dimensions.  If they're invalid it quits the boxcar section of the program and returns to main, otherwise it sets them.
  bool ok;
  ok=test_flat (l, w);		//Gets either "true" or "false" from the test function and puts it into "ok".
  if (!ok)					//If it received "false", it gives the error message.
  {
	cout << "The dimensions you specified were invalid.  The volume of this car cannot be calculated.";
	cout << "\n\n";
	return;
  }
  else						//If it received "true", it sets the dimensions.
  {
	F.set_length(l);
	F.set_width(w);
  }
  
  //Displays volume calculated with new dimensions.
  cout << "This flat car has a volume of " << F.volume(v) << " cubic meters";
  cout << "\n\n";
}
//End Display Flatcar

//Begin Main.
main ()
{
  double l, w, h, r, v;
  
  cout << "\n\n";
  input_boxcar (l, w, h, v);
  input_tankcar (l, r, v);
  input_flatcar (l, w, h, v);
}
//End Main.
