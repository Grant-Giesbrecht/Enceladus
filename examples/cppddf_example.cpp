#include <iostream>
#include <stdio.h>
#include <string>
#include <vector>
#include "../C++/cppddf.hpp"

using namespace std;

int main(){

	double x = 5;

	vector<double> Vout;
	Vout.push_back(2); Vout.push_back(9); Vout.push_back(12); Vout.push_back(20);

	vector<double> Vin;
	Vin.push_back(3); Vin.push_back(5); Vin.push_back(7); Vin.push_back(19);

	vector<vector<double> > V2d;
	V2d.push_back(Vout); V2d.push_back(Vin);
	DDFIO ddf;
	ddf.setHeader("This is a test file.\n\tI was written by a test program :)");
	ddf.add(x, "X", "I am a description");
	ddf.add(Vout, "Vout", "Output");
	ddf.add(Vin, "Vin", "eingang");
	ddf.add(V2d, "Vec_2D", "2D Matrix :)");
	ddf.add(V2d, "Vec_2D2", "I'm a copycat :P");

	cout << "\nNo. Variables: " << to_string(ddf.numVar()) << endl;
	cout << "Variables:\n\t" << ddf.names("mt")[0] << endl;

	ddf.write("../examples/cppddf_out.ddf", ";ov");

	ddf.clear();

	cout << "\nCleared...\n" << endl;

	cout << "\nNo. Variables: " << to_string(ddf.numVar()) << endl;
	cout << "Variables:\n\t" << ddf.names("mt")[0] << endl;

	if (!ddf.load("../examples/read_test.ddf")){
		cout << "Failed to read file." << endl;
		cout << ddf.err() << endl;
	}else{
		cout << "Read file..." << endl;

		cout << "+------------ read_test.ddf ------------------+" << endl;

		cout << ddf.show() << endl;

		cout << "+------------ read_test.ddf ------------------+" << endl;
	}




	return 0;
}
