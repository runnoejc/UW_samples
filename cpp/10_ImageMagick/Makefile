# Jessie Runnoe and Erin Stuhlsatz
# May 2007
# Assignment 10: Image Magick

graph: graph_main.o graph.o
	g++ -o graph graph_main.o graph.o `Magick++-config --ldflags --libs`

graph_main.o: graph_main.cc graph.h
	g++ -c graph_main.cc `Magick++-config --cxxflags --cppflags`

graph.o: graph.h graph.cc
	g++ -c graph.cc `Magick++-config --cppflags --cxxflags --ldflags --libs`

clean:
	rm -f *.o *~

veryclean: clean
	rm -f graph graph.png
