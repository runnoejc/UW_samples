# Matt Pearson & Jessie Runnoe
# Assignment 6
merge_sort: merge_sort_main.o merge_class.o 
	g++ -o merge_sort merge_sort_main.o merge_class.o

merge_sort_main.o: merge_sort_main.cc merge_class.h
	g++ -c merge_sort_main.cc

merge_class.o: merge_class.cc merge_class.h
	g++ -c merge_class.cc

clean:
	rm -f *.o *~

veryclean: clean
	rm -f merge_sort make_random_ints
	rm -f merge_sort.exe make_random_ints.exe
	rm -rf .svn
	rm -f .*.swp
