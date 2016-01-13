using namespace std;
const int FILENAME_LENGTH = 256;
const int MAX_LINES = 100;
const int MAX_COLUMNS = 100;
typedef char filename[FILENAME_LENGTH];
typedef char textline[MAX_COLUMNS+1];

// Does add need to add multiple lines?
// Add should have some thing that, if what you want to add is longer than a line, it won't do it.

class text_ed {
	private:
		textline document[MAX_LINES+1];
		textline buffer[MAX_LINES+1];
		int line_length[MAX_LINES+1];
		int buffer_line_length[MAX_LINES+1];
		int last_line,buffer_last_line;
		filename current_file;
		bool line_numbering;
		
	public:
		text_ed();
		
		bool load_file(filename);
		bool save_file();
		bool save_file(filename);
		bool insert_line(textline src,int n);
		bool delete_lines(int start, int end);
		bool copy_lines(int start, int end, int location);
		bool move_lines(int start, int end, int location);
		bool find(int m, int n, char *word);
		bool replace(int m, int n, char * oldstr, char * newstr);
		
		// Getters & Setters
		bool get_lineNumbering();
		void toggle_lineNumbering();
		void get_filename(filename);
		int get_last_line();
		
		bool display_file(int, int);
};
