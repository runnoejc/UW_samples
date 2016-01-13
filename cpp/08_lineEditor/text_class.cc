#include <fstream>
#include <iostream>
#include <string.h>
#include "text_class.h"
#define MAX(m,n) (m>n ? m : n)
using namespace std;

text_ed::text_ed () {
	last_line = 0;
	buffer_last_line = 0;
	current_file [0];
	line_numbering = false;
}

bool text_ed::load_file ( filename fn ) {
	ifstream f ( fn );
	strncpy ( current_file, fn, FILENAME_LENGTH );
	last_line = 0;
	for (;;) {
		last_line++;
		f.getline ( document[ last_line ],MAX_COLUMNS + 1 );
		if ( f.gcount () == 0 ) {
			last_line--;
			break;
		}
    line_length [ last_line ] = strlen ( document [ last_line ] );
    if ( line_length [ last_line ] == f.gcount () ) {
		f.clear ();
		}
	}
	f.close ();
	return true;
}

bool text_ed::save_file () {
	int i;
	ofstream f (current_file);
	for ( i=1; i<=last_line; i++ ) {
		f << document [ i ] << endl;
		cerr << document[ i ] << endl;	
	}
	f.close ();
	return true;
}

bool text_ed::save_file ( filename fn ) {
  int i;
  ofstream f ( fn );
  for ( i=1; i<=last_line; i++ ) {
	f << document [i] << endl;
	cerr << document [i] << endl;
  }
  f.close();
  return true;
}

bool text_ed::insert_line ( textline src, int n ) {
  int i;
  i = 0;
  
  // If the line will exceed the allowed length it doesn't add the line.
  if ( strlen (document[i]) + strlen (src) > MAX_COLUMNS ) {
	  cerr << "The text you wish to add is too long.  It has not been added." << endl;
	  return false;
  }

  // If adding a line will cause the number of lines to exceed the number of allowed lines, it doesn't add the line.
  if ( last_line + 1 > MAX_LINES ) {
	cerr << "You cannot add another line to this document, it will exceed the maximum number of allowed lines." << endl 
		 <<  "Your text has not been added." << endl;
	return false;
  }
  
  // Moves the lines down to make room for the new one.
  for ( i = last_line; i > n; i-- ) {
	strcpy (document [i+1], document [i]);
	if (i == last_line) {last_line ++;}
  }
  
  // Copies in the new line.
  strcpy (document[n+1], src);
  if ( n == last_line ) { last_line ++; }
  return true;
}

bool text_ed::delete_lines ( int start, int end ) {
  int i, j, k;
  j = start;
  k = end;
  
  // Copies the lines over the ones do be deleted.
  for ( i = end; i <= last_line; i++ ) {
	strcpy (document [j], document [k+1]);
	j++;
	k++;
  }
  
  // Adjusts the last line of the document.
  last_line = j-2;
}

bool text_ed::copy_lines ( int start, int end, int location ) {
int i;
  int dif = end - start + 1;
  
  // Copies the lines to be copied into a buffer.
  for (i = start; i <= end; i++) {
	strcpy (buffer[i], document[i]);
  }
  
  // Rearranges the document to make room for the lines in the new location.
  for ( i = last_line; i >= location; i-- ) {
	strcpy (document [i+dif], document [i]);
	if (i == last_line) {last_line = last_line + dif;}
  }
  
  // Copies the lines from the buffer to the document.
  for (i = location + 1; i <= location + dif; i++) {
	strcpy (document [i], buffer[start]);
	start ++; 
  }
}

bool text_ed::move_lines ( int start, int end, int location ) {
  int i;
  int dif = end - start + 1;
  
  // Copies the lines to a buffer.
  for (i = start; i <= end; i++) {
	strcpy (buffer[i], document[i]);
  }
  
  // Rearranges the document to make room for the new lines 
  for ( i = last_line; i >= location; i-- ) {
	strcpy (document [i+dif], document [i]);
	if (i == last_line) {last_line = last_line + dif;}
  }

  // Copies the lines from the buffer to their new location
  int j = start; 
  for (i = location + 1; i <= location + dif; i++) {
	strcpy (document [i], buffer[j]);
	j ++; 
  }
  
  // Special cases for if deleting uncessary lines
  if ( location > end ) {delete_lines (start, end);}
  else {
	start = start + dif;
	end = end + dif;
    delete_lines (start, end);
  }
}

bool text_ed::find ( int m, int n, char *word ) {
  int i, j, k, w;
  w = 0;
  for ( i = m; i <= n; i++ ) {						// Goes through lines of document
	for (j = 0; document[i][j] != '\0'; j++ ) {		// Goes through characters in line
	  if (word[w] == document[i][j]) {				// If it finds the first letter it's looking for...
		k = j + 1;
		for ( w = 1; word[w] != '\0'; w++ ) {		// It goes on through that line looking for the remaining letters
		  if ( word[w] == document[i][k] ) {		// If it's sucessful it keeps looking
			k++;
		  } else {									// If there's a mismatch it breaks and continues looking for the first letter where it left off
			w = 0;				
			break;
		  } // else
		} // for
		k++;
		if ( word[w] == '\0' ) {					// If it finds the whole word, it prints the line it found and continues through remaining lines
		  	if (line_numbering) {
			  cerr << i << '\t' << document[ i ] << endl;
			} else {
			  cerr << '\t' << document[ i ] << endl;
			}
		} // if
	  } // if
	} // for
  } // for
}


bool text_ed::replace ( int m, int n, char * oldstr, char * newstr ) {
  int i, j, k, w, x, y;
  w = 0;
  for ( i = m; i <= n; i++ ) {					// Same find function rewritten with correct variables and without printing capabilities
	for (j = 0; document[i][j] != '\0'; j++ ) {
	  if (oldstr[w] == document[i][j]) {
		k = j + 1;
		for ( w = 1; oldstr[w] != '\0'; w++ ) {
		  if ( oldstr[w] == document[i][k] ) {
			k++;
		  } else {
			w = 0;
			break;
		  } // else
		} // for
		k --;
		  if ( oldstr [w] == '\0' ) {
		  
		  // Case: If new word is longer than old word
		  if ( strlen ( newstr ) > strlen ( oldstr ) ) {					
			// If new word will cause line to be too long, it doesn't make the switch
			if ( line_length [i] + strlen ( newstr ) - strlen ( oldstr ) > MAX_COLUMNS ) {
			  cerr << "The new word you specified was too long.  The old word has not been replaced." << endl;
			  return false;
			} else {
			  int dif = strlen (newstr) - strlen (oldstr);
			  // Rearranges line and makes space for new word
			  for ( x = line_length [i]; x >= k; x-- ) {
				document [i][x+dif] = document [i][x];
				if (x == line_length[i]) {line_length[i] = line_length[i] + dif;}
			  } // for
			  y = 0; 
			  // Copies new word in starting where old word began
			  for (x = j; x <= k + dif; x++) {
				document [i][x] = newstr [y];
				y ++; 
			  } // for
			} // else	
		  } 
		  // Case: If new word is shorter than old word
		  else {
			int dif = strlen (oldstr) - strlen (newstr);
			// Rearranges characters in line and reduces space to fit new word
			for ( x = k - 2; x <= line_length [i]; x++ ) {
			  document [i][x] = document [i][x+dif];
			  if (x == line_length[i]) {line_length[i] = line_length[i] - dif;}
			} // for
			y = 0;
			// Copies new word in starting where old word began
			for (x = j; x <= k - dif; x++) {
			  document [i][x] = newstr [y];
			  y++;
			} // for
		  } // else	
		} // if
	  } // if
	} // for
  } // for
}


// Getters & Setters

bool text_ed::get_lineNumbering() {
	return line_numbering;
}

void text_ed::toggle_lineNumbering() {
	if (line_numbering == false) line_numbering = true;
	else line_numbering = false;
}

void text_ed::get_filename ( filename ) {
	return;
}
int text_ed::get_last_line () { return last_line; }

bool text_ed::display_file( int m, int n) {
	int i;
	
	// Prints document to screen
	for ( i=m; i<=n; i++ ) {
		// If line numbering is on, it prints the line numbers and then the document lines
		if (line_numbering) {
			cerr << i << '\t' << document[ i ] << endl;
		} else {
			cerr << '\t' << document[ i ] << endl;
		}
	}
	cerr << endl;
	return true;
}
