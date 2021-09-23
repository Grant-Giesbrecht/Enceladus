#include <iostream>
#include <iostream>
#include <limits>

using namespace std;

/*
Taken from:
https://www.oreilly.com/library/view/c-cookbook/0596007612/ch03s08.html

*/
template<typename T>
void showMinMax() {
   cout << "\tMin: " << numeric_limits<T>::min() << endl;
   cout << "\tMax: " << numeric_limits<T>::max() << endl;
   cout << endl;
}

int main(){

    cout << "Size of char: " << sizeof(char) << " byte" << endl;
    cout << "Size of int: " << sizeof(int) << " bytes" << endl;
    cout << "Size of float: " << sizeof(float) << " bytes" << endl;
    cout << "Size of double: " << sizeof(double) << " bytes" << endl;

   cout << "short:" << endl;
   showMinMax<short>();
   cout << "int:" << endl;
   showMinMax<int>();
   cout << "long:" << endl;
   showMinMax<long>();
   cout << "float:" << endl;
   showMinMax<float>();
   cout << "double:" << endl;
   showMinMax<double>();
   cout << "long double:" << endl;
   showMinMax<long double>();
   cout << "unsigned short:" << endl;
   showMinMax<unsigned short>();
   cout << "unsigned int:" << endl;
   showMinMax<unsigned int>();
   cout << "unsigned long:" << endl;
   showMinMax<unsigned long>();

   return 0;
}
