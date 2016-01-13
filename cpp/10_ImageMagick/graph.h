// Jessie Runnoe and Erin Stuhlsatz
// May 2007
// Assignment 10: Image Magick

#define ELEMENTS 501
const double Pi = 3.14159265358979323846;


class graph: public Image {
  private:
	double x[ELEMENTS], fx[ELEMENTS], inc;
	int h[ELEMENTS], v[ELEMENTS];
  public:
	graph();
	double sine (double start, double end);
	double cosine (double start, double end);
	int xtoh ();
	int ytov ();
	void axes ();
	void graph_sine ();
	void graph_cosine ();
};
