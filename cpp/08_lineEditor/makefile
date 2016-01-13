# MAKEFILE for text_editor

text_editor: text_main.o text_class.o
	g++ -o text_editor text_main.o text_class.o

# .o files
text_main.o: text_class.h text_main.cc
	g++ -c text_main.cc

text_class.o: text_class.h text_class.cc
	g++ -c text_class.cc

# CLEAN-UP
clean:
	rm -f *.o *~

veryclean: clean
	rm -f progName_binary
	rm -f progName_binary.exe
	rm -f .*.swp
	rm -rf .svn

