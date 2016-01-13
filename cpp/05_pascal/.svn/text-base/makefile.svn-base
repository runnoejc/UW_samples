# MAKEFILE for pascal_triangle

pascal_triangle: pascal_main.o pascal_class.o
	g++ -o pascal_triangle pascal_main.o pascal_class.o

pascal_main.o: pascal_class.h pascal_main.cc
	g++ -c pascal_main.cc

pascal_class.o: pascal_class.h pascal_class.cc
	g++ -c pascal_class.cc

clean:
	rm -f *.o *~

veryclean: clean
	rm -f pascal_triangle
	rm -f pascal_triangle.exe
