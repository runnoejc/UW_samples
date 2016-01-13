// Matt Pearson & Jessie Runnoe
// Assignment 6
#define M 100
#define NOT_FOUND -1

class data_set {
private:
  // Declares pointers to arrays D and aux
  int *D,*aux;
  // Declares class variables and private functions
  int num_items, capacity;
  int prev_term, prev_index;
  void merge (int, int);
  void mergesort (int,int);
public:
  data_set ();
  ~data_set ();
  void add_data_item(int);
  int get_data_item(int);
  void sort ();
  int find (int);
};

