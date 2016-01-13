# Jessie Runnoe
# Assignment 9
#merge_sort: merge_sort.o merge_class.o 
#	g++ -g -o merge_sort merge_sort.o merge_class.o

#merge_sort.o: merge_sort.cc merge_class.h
#	g++ -g -c merge_sort.cc

#merge_class.o: merge_class.cc merge_class.h
#	g++ -g -c merge_class.cc

string_sort: merge_sort.o sl_string.o
	g++ -o string_sort merge_sort.o sl_string.o

merge_sort.o: merge_sort.cc merge_class.h
	g++ -c merge_sort.cc

sl_int.o: sl_string.cc merge_class.cc merge_class.h
	g++ -c sl_string.cc

clean:
	rm -f *.o *~

veryclean: clean
	rm -f merge_sort make_random_ints
	rm -f merge_sort.exe make_random_ints.exe
	rm -rf .svn
	rm -f .*.swp
