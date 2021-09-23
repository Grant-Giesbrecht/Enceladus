OS := $(shell uname)
ifeq ($(OS),Darwin)
	CC = clang++ -std=c++11
else
	CC = g++ -std=c++11
endif

INCLUDES = -I/Users/grantgiesbrecht/Documents/GitHub
LIBS = -L/Users/grantgiesbrecht/Documents/GitHub/gstd -lgstd -L/Users/grantgiesbrecht/Documents/GitHub/KTable -lktable
OBJS = cppddf.o

simpletest: ../examples/cppddf_example.cpp
	$(CC) -o ../examples/cppddf_example ../examples/cppddf_example.cpp $(INCLUDES) $(LIBS)
	../examples/cppddf_example

testall: ../examples/cppddf_read_all_tests.cpp
	$(CC) -o ../examples/cppddf_read_all_tests ../examples/cppddf_read_all_tests.cpp $(INCLUDES) $(LIBS)
	../examples/cppddf_read_all_tests
