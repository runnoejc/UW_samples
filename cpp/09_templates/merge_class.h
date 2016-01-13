// Jessie Runnoe
// Assignment 9
#define M 100
#define NOT_FOUND -1
#define DEFAULT_CAPACITY 10

template <class dsbt>
class data_set {
private:
  // Declares pointers to arrays D and aux
	dsbt *D,*aux;
  // Declares class variables and private functions
	int num_items, capacity;
	int prev_index;
	dsbt prev_term;
	void merge (int, int);
	void mergesort (int,int);
public:
	data_set ();
	data_set (const data_set & rhs);
	~data_set ();
	void add_item(dsbt);
	void get_array ();
	dsbt get_data_item(int);
	int get_item (int, dsbt&);
	void sort ();
	int find (dsbt);
	data_set & operator += (const data_set & rhs);
	data_set &  operator = (const data_set & rhs);
};
	template <class dsbt>
	data_set<dsbt> operator + (const data_set<dsbt> & lhs, const data_set<dsbt> & rhs);
	
	template <class dsbt>
	istream & operator >> (istream & istr, data_set<dsbt> & rhs);
	
	template <class dsbt>
	ostream & operator << (ostream & ostr, data_set<dsbt> & rhs);

