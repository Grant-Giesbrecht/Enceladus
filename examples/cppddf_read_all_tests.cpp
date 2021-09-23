#include <iostream>
#include <stdio.h>
#include <string>
#include <vector>
#include "../C++/cppddf.hpp"

using namespace std;

int main(){

	vector<string> test_files;
	test_files.push_back("../examples/read_test.ddf");
	test_files.push_back("../examples/read_test2.ddf");
	test_files.push_back("../examples/read_test3.ddf");

	DDFIO ddf;

	for (size_t i = 0 ; i < test_files.size() ; i++){

		cout << " ****************** Testing " << test_files[i] << " **************** " << endl;

		if (!ddf.load(test_files[i])){
			cout << "Failed to read file '" << test_files[i] << "'." << endl;
			cout << ddf.err() << endl;
		}else{
			cout << ddf.show() << endl;
			ddf.clear();
		}
	}

	return 0;
}
