// Matt Pearson & Jessie Runnoe
// Assignment 8 - Line Editor

// A simple text editor.  Type
// 'h' upon runnign to see a list
// of possible commands.

#include <string.h>
#include <iostream>
#include <fstream>
#include "text_class.h"

using namespace std;
string garbage;


//const int LINE_LENGTH = 100;
#define CAPACITY 100
#define COMMAND_CAPACITY 100
#define COMMAND_PROMPT "|-->  "
#define WORD_LENGTH 20

void display_help() {
	cerr << endl << "== AVAILABLE COMMANDS ==" << endl << endl
		<< " h -- Shows this screen." << endl
		<< " g -- Opens a file." << endl
		<< "      Usage:  g <filename> -- Filename is required." << endl
		<< " n -- Toggles line-numbering" << endl
		<< " q -- Exit program without saving." << endl
		<< " x -- Save current file and exit program." << endl
		<< "       Usage:  x <filename> -- Filename is optional." << endl
		<< " p -- Save file." << endl
		<< "       Usage: p <filename> -- Filename is optional." << endl
		<< " a -- Add lines after line 'N'." << endl
		<< "       Usage: a N, type .<enter> to quit." << endl
		<< " t -- Display lines M through N." << endl
		<< "       Usage: t M N" << endl
		<< " d -- Delete lines M through N." << endl
		<< "       Usage: d M N -- Only line M will be deleted if N is unspecified." << endl
		<< " m -- Move lines M through N to directly after line L." << endl
		<< "       Usage: m M N L" << endl
		<< " c -- Copy lines M through N to location directly after line L." << endl
		<< "       Usage: c M N L" << endl
		<< " f -- Display each line between M and N on which 'word' appears." << endl
		<< "       Usage: f M N /word/" << endl
		<< " s -- Substitute string 'new' for the first occurrence of string 'old' on each of lines M through N." << endl
		<< "       Usage: s M N /old/new/" << endl
		<< endl;
	return;
}

main () {
	text_ed T;
	char command_line [COMMAND_CAPACITY], command;
	
	while (command != 'q') {
		cerr << COMMAND_PROMPT;
		cin.getline(command_line,COMMAND_CAPACITY);
		
		// Skip unneeded spaces
		int p=0;
		while (command_line[p]==' ') { p++; }
		command = command_line [p]; p++;
		
		switch (command) {
			case 'h':
				display_help();
				break;

			// Get a file
			// Usage: g <filename-required>
			case 'g':
				char *file;
				int i;
				file = new char [CAPACITY];
				while (command_line [p] == ' ') {p++;}
				for ( i = 0; command_line [p] != '\0'; i++) {	// Puts file name from command line into 'file'
					 file [i] = command_line [p];
					 p++;
				}
				file [i] = '\0';
				T.load_file (file);
				break;
				
			case 'n':		// Toggle line-numbering
				T.toggle_lineNumbering();
				cerr << endl << "Line numbering is now set to " << T.get_lineNumbering() << endl << endl;
				break;
				
			case 'q':		// Quit without saving
				cerr << endl << "Program has quit.  Any unsaved changes have been lost." << endl;
				return 0;
				
			// Save file and exit
			// Usage: x <filename-optional>
			case 'x':
				char *savex;
				int k;
				savex = new char [CAPACITY];
				while ( command_line [p] == ' ' ) {p++;}
				if ( command_line [p] == '\0' ) {
				  T.save_file();
				} else {
				  for ( k = 0; command_line [p] != '\0'; k++ ) {
					savex [k] = command_line [p];
					p++;
				  }
				  savex [k] = '\0';
				  T.save_file (savex);
				}
				cerr << endl << "Program has quit.  Changes to " << file << " have been saved." << endl;
				return 0;
				
			// Save file (a.k.a put current buffer to file)
			// Usage: p <filename-optional>
			case 'p':
				char *saveas;
				int j;
				saveas = new char [CAPACITY];
				while ( command_line[p] == ' ' ) {p++;}
				if ( command_line [p] == '\0' ) {
				  T.save_file();
				} else {
					for ( j = 0; command_line [p] != '\0'; j++ ) {
					saveas [j] = command_line [p];
					p++;
				  }
				  saveas [j] = '\0';
				  T.save_file (saveas);
				}
				break;
				
			// Add lines after line N
			// Usage: a N
			case 'a':
				int o;
				textline text;
				o = 0;	
				while ( command_line [p] == ' ' ) {p++;}
				if ( command_line [p] == '\0' ) {
					   o = 0;
				} else {
					// Converts command line input to integer and puts it into 'o'
					while ( '0' <= command_line [p] && command_line [p] <= '9' ) {
						   o = 10*o + command_line [p] - '0';
						   p++;
					}
				}
					for (;;) {
						cin.getline ( text, MAX_COLUMNS + 1 );
						if (text[0] == '.' && text[1] == '\0') {
						  break;
						}
						T.insert_line (text, o);
    					if ( strlen (text) == cin.gcount () ) {
						  cin.clear ();
						}
						o++;
					}
				break;
				
			// Display lines M through N on the screen
			// Usage: t M N
			case 't':
				int m, n;
				m = 0;
				n = 0;
				while ( command_line [p] == ' ' ) {p++;}
				if ( command_line [p] == '\0' ) {
					m = 0;
					n = T.get_last_line();
				} else {
					while ('0' <= command_line[p] && command_line[p] <='9') {
					  m = 10*m + command_line[p] - '0';
					  p++;
					}
				    while ( command_line [p] == ' ' ) { p++; }
					while ('0' <= command_line[p] && command_line[p] <= '9') {
					  n = 10*n + command_line[p] - '0';
					  p++;
					}
				}
				T.display_file(m, n);
				break;
				
			// Delete lines M through N
			// Will delete only M if not specified N
			// Usage: d M N
			case 'd':
				int q, r;
				q = 0;
				r = 0;
				while ( command_line [p] == ' ' ){p++;}
				if ( command_line [p] == '\0' ) {
				  cerr << "You did not specify which lines to delete.  Please rerun the 'd' command." << endl;
				  break;
				} else {
				  while ('0' <= command_line[p] && command_line[p] <= '9') {
					q = 10*q + command_line[p] - '0';
					p++;
				  }
				  while ( command_line [p] == ' ' ) {p++;}
				  if ( command_line [p] == '\0' ) {
					r = q;
				  } else {
					while ('0' <= command_line[p] && command_line[p] <= '9') {
					  r = 10*r + command_line[p] - '0';
					  p++;
					} // while
				  } // else
				} // else
				
				T.delete_lines (q, r);

				
				break;
				
			// Move lines M through N to location after line L
			// Usage: m M N L
			case 'm':
			
				int s, t, u;
				s = 0;
				t = 0;
				u = 0;
				while ( command_line [p] == ' ' ){p++;}
				if ( command_line [p] == '\0' ) {
				  cerr << "You did not specify which lines to move.  Please rerun the 'm' command." << endl;
				  break;
				} else {
				  while ('0' <= command_line[p] && command_line[p] <= '9') {
					s = 10*s + command_line[p] - '0';
					p++;
				  }
				  while ( command_line [p] == ' ' ) {p++;}
				  if ( command_line [p] == '\0' ) {
					t = s + 1;
				  } else {
					while ('0' <= command_line[p] && command_line[p] <= '9') {
					  t = 10*t + command_line[p] - '0';
					  p++;
					} // while
				  } // else
				  while ( command_line [p] == ' ' ) {p++;}
				  if ( command_line [p] == '\0' ) {
					cerr << "You did not specify where to move the selected lines.  Please rerun the 'm' command." << endl;
					break;
				  } else {
					while ('0' <= command_line[p] && command_line[p] <= '9') {
					  u = 10*u + command_line[p] - '0';
					  p++;
					} // while
				  } // else*/
				} // else
			
				T.move_lines (s, t, u);

				break;
				
			// COPY lines M through N to location after line L
			// Usage: c M N L
			case 'c':
				s = 0;
				t = 0;
				u = 0;
				while ( command_line [p] == ' ' ){p++;}
				if ( command_line [p] == '\0' ) {
				  cerr << "You did not specify which lines to move.  Please rerun the 'm' command." << endl;
				  break;
				} else {
				  while ('0' <= command_line[p] && command_line[p] <= '9') {
					s = 10*s + command_line[p] - '0';
					p++;
				  }
				  while ( command_line [p] == ' ' ) {p++;}
				  if ( command_line [p] == '\0' ) {
					t = s + 1;
				  } else {
					while ('0' <= command_line[p] && command_line[p] <= '9') {
					  t = 10*t + command_line[p] - '0';
					  p++;
					} // while
				  } // else
				  while ( command_line [p] == ' ' ) {p++;}
				  if ( command_line [p] == '\0' ) {
					cerr << "You did not specify where to move the selected lines.  Please rerun the 'm' command." << endl;
					break;
				  } else {
					while ('0' <= command_line[p] && command_line[p] <= '9') {
					  u = 10*u + command_line[p] - '0';
					  p++;
					} // while
				  } // else*/
				} // else
				T.copy_lines (s, t, u);
				break;
				
			// Display each line between M and N on which 'word' appears
			// Usage: f M N /word/
			case 'f':
				m = 0;
				n = 0;
				k = 0;
				char *word;
				word = new char [WORD_LENGTH];
				while ( command_line [p] == ' ' ) {p++;}
				if ( command_line [p] == '\0' ) {
					cerr << "You did not include parameters for this word search.  Please rerun the 'f' command." << endl;
					break;
				} 
				else {
				  while ('0' <= command_line[p] && command_line[p] <= '9') {
					  m = 10*m + command_line[p] - '0';
					  p++;
					} // while
				  while ( command_line [p] == ' ' ) {p++;}
				  if ( command_line [p] == '\0' ) {
					n = m + 1;
				  } else {
					while ('0' <= command_line[p] && command_line[p] <= '9') {
					  n = 10*n + command_line [p] - '0';
					  p++;
					} // while
				  } // else
				 while ( command_line [p] == ' ' ) {p++;}
				 if ( command_line [p] == '\0' ) {
				   cerr << "You did not specify what word to search for.  Please rerun the 'f' command." << endl;
				 } else
				   if ( command_line [p] == '/' ) {
					p++;
					for ( k = 0; command_line [p] != '/'; k++ ) {
					  word [k] = command_line [p];
					  p++;
					} // for
					word [k] = '\0';
				  } else {
					 cerr << "You did not use the correct syntax.  Please rerun the'f' command." << endl;
				  } //else
				} // else 
				T.find(m, n, word);
				break;
				
			// Substitute string 'new' for the first occurrence of string 'old' on each of
			// lines M through N.
			// Usage: s M N /old/new/
			case 's':
				m = 0;
				n = 0;
				k = 0;
				char *neword;
				word = new char [WORD_LENGTH];
				neword = new char [WORD_LENGTH];
				while ( command_line [p] == ' ' ) {p++;}
				if ( command_line [p] == '\0' ) {
					cerr << "You did not include parameters for this command.  Please rerun the 'f' command." << endl;
					break;
				} 
				else {
				  while ('0' <= command_line[p] && command_line[p] <= '9') {
					  m = 10*m + command_line[p] - '0';
					  p++;
					} // while
				  while ( command_line [p] == ' ' ) {p++;}
				  if ( command_line [p] == '\0' ) {
					n = m + 1;
				  } else {
					while ('0' <= command_line[p] && command_line[p] <= '9') {
					  n = 10*n + command_line [p] - '0';
					  p++;
					} // while
				  } // else
				 while ( command_line [p] == ' ' ) {p++;}
				 if ( command_line [p] == '\0' ) {
					cerr << "You did not specify what word to replace.  Please rerun the 'f' command." << endl;
					break;
				 } else
				   if ( command_line [p] == '/' ) {
					p++;
					for ( k = 0; command_line [p] != '/'; k++ ) {
					  word [k] = command_line [p];
					  p++;
					} // for
					word [k] = '\0';
				  } else {
					  cerr << "You did not use the correct syntax.  Please rerun the'f' command." << endl;
					  break;
				  } //else

				 while ( command_line [p] == ' ' ) {p++;}
				 if ( command_line [p] == '\0' ) {
				   cerr << "You did not specify a new word.  Please rerun the 'f' command." << endl;
				 } else
				   if ( command_line [p] == '/' ) {
					p++;
					for ( k = 0; command_line [p] != '/'; k++ ) {
					  neword [k] = command_line [p];
					  p++;
					} // for
					neword [k] = '\0';
				  } else {
					 cerr << "You did not use the correct syntax.  Please rerun the'f' command." << endl;
					 break;
				  } //else
				} // else

				T.replace(m, n, word, neword);

				break;
				
			default:
				cerr << "Invalid command.  Type 'h' to view the list of commands." << endl << endl;
				break;
		}
	}
}
