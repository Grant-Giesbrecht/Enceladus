#ifndef CPPDDF_HPP
#define CPPDDF_HPP

#include <cctype>
#include <cstdio>
#include <string>
#include <vector>
#include <iostream>
#include <fstream>
#include <regex>
#include <gstd/gstd.hpp>
#include <ktable.hpp>

#define CURRENT_VERSION 2.0

std::string bool_to_string(bool b);
bool is_2d(std::string);

//***************************************************************************//
//**			TYPE DEFINITIONS										   **//
//***************************************************************************//


/*
Contains every available type of data. Makes operator() able to return
any variable and a '.<type>' after the operator() call allows quick
initialization of values.

ex:
vector<double> Vin = ddf("Vin").md;  //s.t. ddf is a DDFItem
*/
typedef struct{
	//Non-matrix variables
	double d;
	std::string s;
	bool b;

	//1D Matrices
	std::vector<double> md;
	std::vector<std::string> ms;
	std::vector<bool> mb;

	//2D Matrices
	std::vector<std::vector<double> > md2;
	std::vector<std::vector<std::string> > ms2;
	std::vector<std::vector<bool> > mb2;
}DDFItem;

/*
The DDFFlatItem, ..1DITem, and ..2DItem are used to make a simple database of
variables inside the DDFIO object. Three vectors, once of each type of struct
contain all of the object's variables. One vector of DDFItems could contain them
all, but would waste more memory as 1/9 variables in ea. struct would be used
instead of 1/3. This especially helps save memory when few matrices or 2D
matrices are used.
*/

typedef struct{
	double d;
	std::string s;
	bool b;

	std::string name;
	char type;
	std::string description; //TODO: Add code to verify desc doesn't contain newline when added by user
}DDFFlatItem;

typedef struct{
	std::vector<double> md;
	std::vector<std::string> ms;
	std::vector<bool> mb;

	std::string name;
	char type;
	std::string description;
}DDF1DItem;

typedef struct{
	std::vector<std::vector<double> > md2;
	std::vector<std::vector<std::string> > ms2;
	std::vector<std::vector<bool> > mb2;

	std::string name;
	char type;
	std::string description;
}DDF2DItem;

//***************************************************************************//
//**			CLASS DEFINITIONS									   **//
//***************************************************************************//

class DDFIO{
public:

	//************ INITIALIZERS

	DDFIO();
	DDFIO(std::string fileIn);

	//************ ADD VARIABLES

	//Non-matrix variables
	void add(double newVar, std::string varName, std::string desc="");
	void add(std::string newVar, std::string varName, std::string desc="");
	void add(bool newVar, std::string varName, std::string desc="");

	//1D Matrices
	void add(std::vector<double> newVar, std::string varName, std::string desc="");
	void add(std::vector<std::string> newVar, std::string varName, std::string desc="");
	void add(std::vector<bool> newVar, std::string varName, std::string desc="");

	//2D Matrices
	void add(std::vector<std::vector<double> > newVar, std::string varName, std::string desc="");
	void add(std::vector<std::vector<std::string> > newVar, std::string varName, std::string desc="");
	void add(std::vector<std::vector<bool> > newVar, std::string varName, std::string desc="");

	//TODO: Add way to edit variables

	//*********** READ VARIABLES

	DDFItem operator()(std::string varName);


	//********** FILE I/O

	std::string swrite(std::string fileOut, std::string options=""); //TODO: swrite should not have a 'fileOut' parameter
	bool write(std::string fileOut, std::string options="");
	bool load(std::string fileIn, std::string options="");
	bool loadDDF_V1(std::string fileIn, std::string options="");
	bool clload(std::string fileIn);


	//*************** VARIABLE MANAGEMENT

	bool checkContains(std::vector<std::string> names);
	void clear();
	size_t numVar();

	//*************** HEADER

	void setHeader(std::string h);
	std::string getHeader();

	double getVersion();
	std::string err();

	//************** PRINTING

	std::vector<std::string> names(std::string options="");
	std::string show();


private:

	std::vector<DDFFlatItem> variablesFlat;
	std::vector<DDF1DItem> variables1D;
	std::vector<DDF2DItem> variables2D;

	void initialize();

	bool isValidName(std::string name);
	bool nameInUse(std::string name);

	void sortMatrices();
	size_t matrixLength(DDF1DItem m);
	size_t matrixLength(DDF2DItem m);

	double linaccess(std::vector<std::vector<double> > m, size_t idx);
	bool linaccess(std::vector<std::vector<bool> > m, size_t idx);
	std::string linaccess(std::vector<std::vector<std::string> > m, size_t idx);

	bool isRowEnd(DDF2DItem m, size_t idx);

	void init_ktable(KTable& kt);

	std::string header;
	double fileVersion; //version of read file

	std::string err_str; //Error data string

};

//***************************************************************************//
//**			FUNCTION DEFINITIONS									   **//
//***************************************************************************//


//***************************************************************************//
//***************** INITIALIZERS

DDFIO::DDFIO(){
	initialize();
}

/*
Reads the input file. Same as calling blank initializer combined with load()
*/
DDFIO::DDFIO(std::string fileIn){

	initialize();

	load(fileIn);
}

/*
Initialize the object
*/
void DDFIO::initialize(){

	fileVersion = CURRENT_VERSION;

}

//***************************************************************************//
//*************** ADD VARIABLES

//****** Non-matrix variables **********

/*
Adds a variable to the DDFIO object. Retuns without adding variable if name is
invalid or already in use.
*/


void DDFIO::add(double newVar, std::string varName, std::string desc){

	//Check that name is valid and unclaimed
	if ( (!isValidName(varName)) || nameInUse(varName)) return;

	DDFFlatItem newItem; 	//Create new item
	newItem.d = newVar;		//Give new item correct value
	newItem.name = varName; //Give new item
	newItem.type = 'd';		//Specify type
	newItem.description = desc; //Add description

	variablesFlat.push_back(newItem); //Add to vector of varaiables

}

void DDFIO::add(std::string newVar, std::string varName, std::string desc){

	//Check that name is valid and unclaimed
	if ( (!isValidName(varName)) || nameInUse(varName)) return;

	DDFFlatItem newItem; 	//Create new item
	newItem.s = newVar;		//Give new item correct value
	newItem.name = varName; //Give new item
	newItem.type = 's';		//Specify type
	newItem.description = desc; //Add description

	variablesFlat.push_back(newItem); //Add to vector of varaiables

}

void DDFIO::add(bool newVar, std::string varName, std::string desc){

	//Check that name is valid and unclaimed
	if ( (!isValidName(varName)) || nameInUse(varName)) return;

	DDFFlatItem newItem; 	//Create new item
	newItem.b = newVar;		//Give new item correct value
	newItem.name = varName; //Give new item
	newItem.type = 'b';		//Specify type
	newItem.description = desc; //Add description

	variablesFlat.push_back(newItem); //Add to vector of varaiables

}

//******  1D matrix variables **********

void DDFIO::add(std::vector<double> newVar, std::string varName, std::string desc){

	//Check that name is valid and unclaimed
	if ( (!isValidName(varName)) || nameInUse(varName)) return;

	DDF1DItem newItem; 		//Create new item
	newItem.md = newVar;	//Give new item correct value
	newItem.name = varName; //Give new item
	newItem.type = 'd';		//Specify type
	newItem.description = desc; //Add description

	variables1D.push_back(newItem); //Add to vector of varaiables

}

void DDFIO::add(std::vector<std::string> newVar, std::string varName, std::string desc){

	//Check that name is valid and unclaimed
	if ( (!isValidName(varName)) || nameInUse(varName)) return;

	DDF1DItem newItem; 		//Create new item
	newItem.ms = newVar;	//Give new item correct value
	newItem.name = varName; //Give new item
	newItem.type = 's';		//Specify type
	newItem.description = desc; //Add description

	variables1D.push_back(newItem); //Add to vector of varaiables

}

void DDFIO::add(std::vector<bool> newVar, std::string varName, std::string desc){

	//Check that name is valid and unclaimed
	if ( (!isValidName(varName)) || nameInUse(varName)) return;

	DDF1DItem newItem; 		//Create new item
	newItem.mb = newVar;	//Give new item correct value
	newItem.name = varName; //Give new item
	newItem.type = 'b';		//Specify type
	newItem.description = desc; //Add description

	variables1D.push_back(newItem); //Add to vector of varaiables

}

//******  2D matrix variables **********

void DDFIO::add(std::vector<std::vector<double> > newVar, std::string varName, std::string desc){

	//Check that name is valid and unclaimed
	if ( (!isValidName(varName)) || nameInUse(varName)) return;

	DDF2DItem newItem; 		//Create new item
	newItem.md2 = newVar;	//Give new item correct value
	newItem.name = varName; //Give new item
	newItem.type = 'd';		//Specify type
	newItem.description = desc; //Add description

	variables2D.push_back(newItem); //Add to vector of varaiables

}

void DDFIO::add(std::vector<std::vector<std::string> > newVar, std::string varName, std::string desc){

	//Check that name is valid and unclaimed
	if ( (!isValidName(varName)) || nameInUse(varName)) return;

	DDF2DItem newItem; 		//Create new item
	newItem.ms2 = newVar;	//Give new item correct value
	newItem.name = varName; //Give new item
	newItem.type = 's';		//Specify type
	newItem.description = desc; //Add description

	variables2D.push_back(newItem); //Add to vector of varaiables

}

void DDFIO::add(std::vector<std::vector<bool> > newVar, std::string varName, std::string desc){

	//Check that name is valid and unclaimed
	if ( (!isValidName(varName)) || nameInUse(varName)) return;

	DDF2DItem newItem; 		//Create new item
	newItem.mb2 = newVar;	//Give new item correct value
	newItem.name = varName; //Give new item
	newItem.type = 'b';		//Specify type
	newItem.description = desc; //Add description

	variables2D.push_back(newItem); //Add to vector of varaiables

}

//***************************************************************************//
//*************** FILE I/O

/*
Writes the currently loaded variables to a DDF file on disk.

Options: (Order does not matter. Case-sensitive)
	v: Save all matrices as vertical
	o: Optimize size by removing lines intended to improve human-readability.
	d: Decapitate - ie. omit header
	-: Do not print version statement. WARNING: This will make the file unreadable.
		Don't use it unless you know what you're doing.
	;: Terminate variable statements with the optional semicolon
	s: Sort vectors largest to smallest
	u: Undocumented - variable descriptions are not printed

In the event of an error, it returns a blank string.
*/
std::string DDFIO::swrite(std::string fileOut, std::string options){ //TODO: Impliment write()

	std::string ddf; //This is the string which will contain the file

	bool vertical_mode = false;
	bool optimize = false;
	bool decapitate = false;
	bool skip_version = false;
	std::string term_char = "";
	bool sort_mats = false;
	bool show_descriptions = true;

	//Read in options
	if (options.find("v", 0) != std::string::npos){
		vertical_mode = true;
	}
	if (options.find("o", 0) != std::string::npos){
		optimize = true;
	}
	if (options.find("d", 0) != std::string::npos){
		decapitate = true;
	}
	if (options.find("-", 0) != std::string::npos){
		skip_version = true;
	}
	if (options.find(";", 0) != std::string::npos){
		term_char = ";";
	}
	if (options.find("s", 0) != std::string::npos){
		sort_mats = true;
	}
	if (options.find("u", 0) != std::string::npos){
		show_descriptions = false;
	}

	//********************** Write version statement *************************//
	ddf = ddf + "#VERSION " + std::string(std::to_string(CURRENT_VERSION)) + "\n";
	if (!optimize) ddf = ddf + "\n";

	//*********************** Write header statement *************************//
	if (header.length() > 0 && !decapitate){
		ddf = ddf + "#HEADER\n" + header + "\n#HEADER\n";
		if (!optimize) ddf = ddf + "\n";
	}


	//********************** Write Flat Variables ****************************//

	//For each variable...
	for (size_t i = 0 ; i < variablesFlat.size() ; i++){

		//Write type, name, value
		switch(variablesFlat[i].type){
			case('d'):
				ddf = ddf + "d " + variablesFlat[i].name + " " + gstd::to_gstring(variablesFlat[i].d) + term_char; //Add variable
				if (variablesFlat[i].description.length() > 0 && show_descriptions) ddf = ddf + " ?" + variablesFlat[i].description; //Add description if applicable
				ddf = ddf + "\n"; //Add newline
				break;
			case('b'):
				ddf = ddf + "b " + variablesFlat[i].name + " " + bool_to_string(variablesFlat[i].b) + term_char;  //Add variable
				if (variablesFlat[i].description.length() > 0 && show_descriptions) ddf = ddf + " ?" + variablesFlat[i].description; //Add description if applicable
				ddf = ddf + "\n"; //Add newline
				break;
			case('s'):
				ddf = ddf + "s " + variablesFlat[i].name + " \"" + variablesFlat[i].s + "\"" + term_char;  //Add variable
				if (variablesFlat[i].description.length() > 0 && show_descriptions) ddf = ddf + " ?" + variablesFlat[i].description; //Add description if applicable
				ddf = ddf + "\n"; //Add newline
				break;
			default:
				return ""; //An error occured
		}

	}

	//Sort matrices if requested or requried (required for vertical writing)
	if (sort_mats || vertical_mode) sortMatrices();

	if (vertical_mode){ //******************** Write matrices - Vertical Mode ***********//

		//TODO: Optimized veritcal mode not using KTable, instead using spaces

		{
			//************************ 1D ******************************

			//Start vertical block
			ddf = ddf + "#VERTICAL\n";
			if (!optimize) ddf = ddf + "\n";

			//To keep everything aligned, use KTable
			KTable kt;

			//Write types
			//
			std::vector<std::string> trow;
			for (size_t i = 0 ; i < variables1D.size() ; i++){
				switch(variables1D[i].type){
					case('d'):
						trow.push_back("m<d>");
						break;
					case('b'):
						trow.push_back("m<b>");
						break;
					case('s'):
						trow.push_back("m<s>");
						break;
					default:
						return ""; //An error occured
				}
			}
			//
			kt.row(trow);

			//Write names
			//
			trow.clear();
			for (size_t i = 0 ; i < variables1D.size() ; i++){
				trow.push_back(variables1D[i].name);
			}
			//
			kt.row(trow);



			//Write descriptions
			//
			if (show_descriptions){

				trow.clear();

				bool all_descr_blank = true; //Will let code skip description if all blank

				trow.clear();
				for (size_t i = 0 ; i < variables1D.size() ; i++){ //Get descr for 1D vars

					if (variables1D[i].description.find("?", 0) != std::string::npos){ //Skip desc if it contains key symbol '?''
						trow.push_back("?");
					}else{
						trow.push_back("?" + variables1D[i].description); //Else print desc
						all_descr_blank = false;
					}

				}

				if (!all_descr_blank) kt.row(trow);

			}

			//Write data lines
			//
			bool still_printing;
			size_t row = 0;
			do{ //While any matrix still has data to print...

				trow.clear();

				still_printing = false;

				for (size_t i = 0 ; i < variables1D.size() ; i++){ //For each 1D matrix...

					switch(variables1D[i].type){ //Find out its type...
						case('d'):
							if (row < variables1D[i].md.size()){ //See if it has data to print...
								still_printing  = true; //Set printing to true
								trow.push_back(gstd::to_gstring(variables1D[i].md[row])); //Add its data point
							}
							break;
						case('b'):
							if (row < variables1D[i].mb.size()){ //See if it has data to print...
								still_printing  = true; //Set printing to true
								trow.push_back(bool_to_string(variables1D[i].mb[row])); //Add its data point
							}
							break;
						case('s'):
							if (row < variables1D[i].ms.size()){ //See if it has data to print...
								still_printing  = true; //Set printing to true
								trow.push_back("\"" + variables1D[i].ms[row] + "\""); //Add its data point
							}
							break;
					}

				}

				kt.row(trow);

				row++;

			}while(still_printing);




			init_ktable(kt); //TODO: Alignment is wrong if this is NOT caleld at end. Put's left align columns right aligned.


			//Add table's string as vertical matrix statement
			ddf = ddf + kt.str();


			//End vertical block
			if (!optimize) ddf = ddf + "\n";
			ddf = ddf + "#VERTICAL\n";
		}

		{
			//******************************** 2D ******************************

			//Start vertical block
			if (!optimize) ddf = ddf + "\n";
			ddf = ddf + "#VERTICAL\n";
			if (!optimize) ddf = ddf + "\n";

			//To keep everything aligned, use KTable
			KTable kt;

			//Write types
			//
			std::vector<std::string> trow;
			for (size_t i = 0 ; i < variables2D.size() ; i++){
				switch(variables2D[i].type){
					case('d'):
						trow.push_back("m<d>");
						break;
					case('b'):
						trow.push_back("m<b>");
						break;
					case('s'):
						trow.push_back("m<s>");
						break;
					default:
						return ""; //An error occured
				}
			}
			//
			kt.row(trow);

			//Write names
			//
			trow.clear();
			for (size_t i = 0 ; i < variables2D.size() ; i++){
				trow.push_back(variables2D[i].name);
			}
			//
			kt.row(trow);

			//Write descriptions
			//
			if (show_descriptions){

				trow.clear();

				bool all_descr_blank = true; //Will let code skip description if all blank

				trow.clear();
				for (size_t i = 0 ; i < variables2D.size() ; i++){ //Get descrs for 2D vars

					if (variables2D[i].description.find("?", 0) != std::string::npos){ //Skip desc if it contains key symbol '?''
						trow.push_back("?");
					}else{
						trow.push_back("?" + variables2D[i].description); //Else print desc
						all_descr_blank = false;
					}

				}

				if (!all_descr_blank) kt.row(trow);

			}

			//Write data lines
			//
			bool still_printing;
			size_t row = 0;
			do{ //While any matrix still has data to print...

				trow.clear();

				still_printing = false;
				for (size_t i = 0 ; i < variables2D.size() ; i++){ //For each 2D variable

					switch(variables2D[i].type){ //Find out its type...
						case('d'):
							if (row < matrixLength(variables2D[i])){ //See if it has data to print...
								still_printing  = true; //Set printing to true
								std::string tstr = gstd::to_gstring(linaccess(variables2D[i].md2, row));
								if (isRowEnd(variables2D[i], row)) tstr = tstr + ";";
								trow.push_back(tstr); //Add its data point

							}
							break;
						case('b'):
							if (row < matrixLength(variables2D[i])){ //See if it has data to print...
								still_printing  = true; //Set printing to true
								std::string tstr = bool_to_string(linaccess(variables2D[i].mb2, row));
								if (isRowEnd(variables2D[i], row)) tstr = tstr + ";";
								trow.push_back(tstr); //Add its data point
							}
							break;
						case('s'):
							if (row < matrixLength(variables2D[i])){ //See if it has data to print...
								still_printing  = true; //Set printing to true
								std::string tstr = "\"" + linaccess(variables2D[i].ms2, row) + "\"";
								if (isRowEnd(variables2D[i], row)) tstr = tstr + ";";
								trow.push_back(tstr); //Add its data point
							}
							break;
					}
				}

				kt.row(trow);

				row++;

			}while(still_printing);




			init_ktable(kt); //TODO: Alignment is wrong if this is NOT caleld at end. Put's left align columns right aligned.


			//Add table's string as vertical matrix statement
			ddf = ddf + kt.str();


			//End vertical block
			if (!optimize) ddf = ddf + "\n";
			ddf = ddf + "#VERTICAL\n";
		}


	}else{ //******************** Write matrices - Horizontal Mode **********************//

		//********************** Write 1D Variables - Horizontal ****************************//

		//For each variable...
		for (size_t i = 0 ; i < variables1D.size() ; i++){

			switch(variables1D[i].type){
				case('d'):

					//print type, name, open brackets
					ddf = ddf + "m<d> " + variables1D[i].name + " [";

					//For each element...
					for (size_t k = 0 ; k < variables1D[i].md.size() ; k++){
						if (k != 0) ddf = ddf + ", "; //Add comma if not first element
						ddf = ddf + gstd::to_gstring(variables1D[i].md[k]); //Add variable string
					}

					ddf = ddf + "]" + term_char;  //Add termination
					if (variables1D[i].description.length() > 0 && show_descriptions) ddf = ddf + " ?" + variables1D[i].description; //Add description if applicable
					ddf = ddf + "\n"; //Add newline
					break;
				case('b'):

					//print type, name, open brackets
					ddf = ddf + "m<b> " + variables1D[i].name + " [";

					//For each element...
					for (size_t k = 0 ; k < variables1D[i].mb.size() ; k++){
						if (k != 0) ddf = ddf + ", "; //Add comma if not first element
						ddf = ddf + bool_to_string(variables1D[i].mb[k]); //Add variable string
					}

					ddf = ddf + "]" + term_char;  //Add termination
					if (variables1D[i].description.length() > 0 && show_descriptions) ddf = ddf + " ?" + variables1D[i].description; //Add description if applicable
					ddf = ddf + "\n"; //Add newline
					break;
				case('s'):

					//print type, name, open brackets
					ddf = ddf + "m<s> " + variables1D[i].name + " [";

					//For each element...
					for (size_t k = 0 ; k < variables1D[i].ms.size() ; k++){
						if (k != 0) ddf = ddf + ", "; //Add comma if not first element
						ddf = ddf + "\"" + variables1D[i].ms[k] + "\""; //Add variable string
					}

					ddf = ddf + "]" + term_char;  //Add termination
					if (variables1D[i].description.length() > 0 && show_descriptions) ddf = ddf + " ?" + variables1D[i].description; //Add description if applicable
					ddf = ddf + "\n"; //Add newline
					break;

				default:
					return ""; //An error occured
			}
		}

		//********************** Write 2D Variables - Horizontal ****************************//

		//For each variable...
		for (size_t i = 0 ; i < variables2D.size() ; i++){

			switch(variables2D[i].type){
				case('d'):

					//print type, name, open brackets
					ddf = ddf + "m<d> " + variables2D[i].name + " [";

					//For each row...
					for (size_t k = 0 ; k < variables2D[i].md2.size() ; k++){

						if (k != 0) ddf = ddf + "; "; //Add semicolon if not first row

						//Write row
						for (size_t j = 0 ; j < variables2D[i].md2[k].size() ; j++){ //For each element...
							if (j != 0) ddf = ddf + ", "; //Add comma if not first element
							ddf = ddf + gstd::to_gstring(variables2D[i].md2[k][j]); //Add variable string
						}
					}

					ddf = ddf + "]" + term_char;  //Add termination
					if (variables2D[i].description.length() > 0 && show_descriptions) ddf = ddf + " ?" + variables2D[i].description; //Add description if applicable
					ddf = ddf + "\n"; //Add newline
					break;
				case('b'):

					//print type, name, open brackets
					ddf = ddf + "m<b> " + variables2D[i].name + " [";

					//For each row...
					for (size_t k = 0 ; k < variables2D[i].mb2.size() ; k++){

						if (k != 0) ddf = ddf + "; "; //Add semicolon if not first row

						//Write row
						for (size_t j = 0 ; j < variables2D[i].mb2[k].size() ; j++){ //For each element...
							if (j != 0) ddf = ddf + ", "; //Add comma if not first element
							ddf = ddf + bool_to_string(variables2D[i].mb2[k][j]); //Add variable string
						}
					}

					ddf = ddf + "]" + term_char;  //Add termination
					if (variables2D[i].description.length() > 0 && show_descriptions) ddf = ddf + " ?" + variables2D[i].description; //Add description if applicable
					ddf = ddf + "\n"; //Add newline
					break;
				case('s'):

					//print type, name, open brackets
					ddf = ddf + "m<s> " + variables2D[i].name + " [";

					//For each row...
					for (size_t k = 0 ; k < variables2D[i].ms2.size() ; k++){

						if (k != 0) ddf = ddf + "; "; //Add semicolon if not first row

						//Write row
						for (size_t j = 0 ; j < variables2D[i].ms2[k].size() ; j++){ //For each element...
							if (j != 0) ddf = ddf + ", "; //Add comma if not first element
							ddf = ddf + "\"" + variables2D[i].ms2[k][j] + "\""; //Add variable string
						}
					}

					ddf = ddf + "]" + term_char;  //Add termination
					if (variables2D[i].description.length() > 0 && show_descriptions) ddf = ddf + " ?" + variables2D[i].description; //Add description if applicable
					ddf = ddf + "\n"; //Add newline
					break;
				default:
					return ""; //An error occured
			}
		}

	}



	return ddf;
}

/*
Writes a DDF file to disk. Returns true if successful, else false. Options are passed
to DDFIO::swrite - see its documentation for options.
*/
bool DDFIO::write(std::string fileOut, std::string options){

	//Generate string
	std::string fileString = swrite(fileOut, options);

	if (fileString == ""){ //Error occured in swrite
		return false;
	}

	//Write to file
	std::ofstream out(fileOut);
	if (!out.is_open()){
		return false;
	}
    out << fileString;
    out.close();

	return true;
}

/*
Reads a DDF file. Returns true if successful, else false.

TODO: Accept earlier standards.
*/
bool DDFIO::load(std::string fileIn, std::string options){ //TODO: Impliment load()

	//Open file - return if fail
	std::ifstream file(fileIn.c_str());
	if (!file.is_open()){
		return false;
	}

	//Read first line - get version
 	std::string line;
    getline(file, line);
	file.close();


	//Read version
	try{
		fileVersion = stod(line.substr(9));
	}catch(...){
		return false;
	}

	//Call appropriate read function
	if (fileVersion < 2){
		std::cout << "ERROR: Version 1.x not supported yet" << std::endl;
		return false;
	}else if(fileVersion < 3){
		return loadDDF_V1(fileIn, options);
	}

	return false;
}

/*
Read DDF version 1 file. Returns true if read success.
*/
bool DDFIO::loadDDF_V1(std::string fileIn, std::string options){

	//Open file - return if fail
	std::ifstream file(fileIn.c_str());
	if (!file.is_open()){
		return false;
	}

	std::string line;
	std::vector<gstd::string_idx> words;
	size_t lineNum = 0;
	std::regex matrix_identifier("m<.>");
	while (getline(file, line)){ //For each line in file...

		lineNum++;

		//Break line into words...
		// std::string lineParse = line;
		// gstd::ensure_whitespace(lineParse, ";[]"); //Ensure semicolons are picked up as tokens
		words = gstd::parseIdx(line, " \t", ";[]");

		if (words.size() < 1) continue; //Skip blank lines

		if (words[0].str == "#VERSION"){ //Version statement

			//Ensure 2 words present
			if (words.size() != 2){
				err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tVersion statement accepts exactly 2 words.";
				return false;
			}

			//Read version statement
			try{
				fileVersion = std::stod(words[1].str);
			}catch(...){
				err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFailed to read version number.";
				return false;
			}

		}else if(words[0].str == "#HEADER"){

			header = ""; //Clear header
			size_t openedOnLine = lineNum;

			bool foundHeader = false;
			while (getline(file, line)){ //Keep reading lines until closing header found

				lineNum++;

				//Break line into words...
				gstd::ensure_whitespace(line, ";"); //Ensure semicolons are picked up as tokens
				words = gstd::parseIdx(line, " \t");

				//TODO: Should I remove this so blank spaces in header are kept?
				if (words.size() < 1) continue; //Skip blank lines

				if(words[0].str == "#HEADER"){ //Is a closing header statement
					foundHeader = true;
					break;
				}else{ //Is part of the header...

					if (header.length() == 0){
						header = line;
					}else{
						header = header + "\n" + line;
					}

				}

			}

			//Ensure end of file was not reached before header found
			if (!foundHeader){
				err_str = "Failed on line " + std::to_string(openedOnLine) + ".\n\tFailed to find closing #HEADER statement.";
				return false;
			}

        }else if(words[0].str == "//"){ //Is a comment

            continue;

        }else if (words[0].str == "d" || words[0].str == "b" || words[0].str == "s" || std::regex_match(words[0].str, matrix_identifier)){ //Inline variables

			//Ensure 3+ words exist
			if (words.size() < 3){
				err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tInsufficient number of tokens for inline variable statement.";
				return false;
			}

			//Read variable name, ensure is valid
			if (!isValidName(words[1].str)){
				err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tInvalid variable name '" + words[1].str +"'.";
				return false;
			}

			//Read value
			size_t optional_features_start = 3;
			if (words[0].str == "d"){ //Double

				DDFFlatItem temp;
				temp.name = words[1].str;
				temp.type = 'd';
				try{
					temp.d = stod(words[2].str);
				}catch(...){
					err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Failed to interpret '" + words[2].str + "' as a double.";
					return false;
				}
				optional_features_start = 3;

				//Read optional arguments/features
				bool allow_semi = true;
				bool in_desc = false;
				for (size_t i = optional_features_start ; i < words.size() ; i++){

					if (words[i].str == ";"){
						if (!allow_semi){
							err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Detected excessive semicolons.";
							return false;
						}
						allow_semi = false;
					}else if(words[i].str == "?" || (words[i].str.length() > 0 && words[i].str[0] == '?')){
						in_desc = true;
						temp.description = line.substr(words[i].idx-words[i].str.length()+2); //The description is the string of characters starting immediately after the questionmark TODO: this likely includes comments as well. Instead of handling comments as they come up, why not run over the document once and purge all inline comments.
					}else if(words[i].str == "//"){
						break; //the rest is a comment - exit loop
					}

				}

				variablesFlat.push_back(temp);

			}else if(words[0].str == "b"){ //Boolean

				DDFFlatItem temp;
				temp.name = words[1].str;
				temp.type = 'b';
				try{
					temp.b = gstd::to_bool(words[2].str);
				}catch(...){
					err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Failed to interpret '" + words[2].str + "' as a bool.";
					return false;
				}
				optional_features_start = 3;

				//Read optional arguments/features
				bool allow_semi = true;
				bool in_desc = false;
				for (size_t i = optional_features_start ; i < words.size() ; i++){

					if (words[i].str == ";"){
						if (!allow_semi){
							err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Detected excessive semicolons.";
							return false;
						}
						allow_semi = false;
					}else if(words[i].str == "?" || (words[i].str.length() > 0 && words[i].str[0] == '?')){
						in_desc = true;
						temp.description = line.substr(words[i].idx+1); //The description is the string of characters starting immediately after the questionmark
					}else if(words[i].str == "//"){
						break; //the rest is a comment - exit loop
					}

				}

				variablesFlat.push_back(temp);

			}else if(words[0].str == "s"){ //string

				DDFFlatItem temp;
				temp.name = words[1].str;
				temp.type = 's';
				try{

					size_t end;
					temp.s = gstd::get_string(line, end, words[0].idx+1);

					//Find word where to start to looking for optional features
					for (size_t i = 0 ; i < words.size() ; i++){
						if (words[i].idx+words[i].str.length() > end){
							optional_features_start = i;
							break;
						}
					}

				}catch(...){
					err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Failed to interpret '" + words[2].str + "' as a string.";
					return false;
				}
				optional_features_start = 3;

				//Read optional arguments/features
				bool allow_semi = true;
				bool in_desc = false;
				for (size_t i = optional_features_start ; i < words.size() ; i++){

					if (words[i].str == ";"){
						if (!allow_semi){
							err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Detected excessive semicolons.";
							return false;
						}
						allow_semi = false;
					}else if(words[i].str == "?" || (words[i].str.length() > 0 && words[i].str[0] == '?')){
						in_desc = true;
						temp.description = line.substr(words[i].idx+1); //The description is the string of characters starting immediately after the questionmark
					}else if(words[i].str == "//"){
						break; //the rest is a comment - exit loop
					}

				}

				variablesFlat.push_back(temp);

			}else if(words[0].str == "m<d>" && !is_2d(line)){ //Double matrix 1D

				DDF1DItem temp;
				temp.name = words[1].str;
				temp.type = 'd';

				size_t start = line.find("[", 0);
				size_t end = line.find("]", 0);
				if (start == std::string::npos || end == std::string::npos){
					err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Failed to find square brackets.";
					return false;
				}

				std::string mat_str = line.substr(start+1, end-start-1);
				try{
					temp.md = gstd::to_dvec(mat_str);
				}catch(...){
					err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Failed to interpret '" + mat_str + "' as a matrix of doubles.";
					return false;
				}

				//Find where data ends, optional features begin
				optional_features_start = 4;
				for (; optional_features_start < words.size() ; optional_features_start++){
					if (words[optional_features_start].idx > end){
						break;
					}
				}


				//Read optional arguments/features
				bool allow_semi = true;
				bool in_desc = false;
				for (size_t i = optional_features_start ; i < words.size() ; i++){

					if (words[i].str == ";"){
						if (!allow_semi){
							err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Detected excessive semicolons.";
							return false;
						}
						allow_semi = false;
					}else if(words[i].str == "?" || (words[i].str.length() > 0 && words[i].str[0] == '?')){
						in_desc = true;
						temp.description = line.substr(words[i].idx+1); //The description is the string of characters starting immediately after the questionmark
					}else if(words[i].str == "//"){
						break; //the rest is a comment - exit loop
					}

				}

				variables1D.push_back(temp);

			}else if(words[0].str == "m<b>" && !is_2d(line)){ //Bool matrix 1D

				DDF1DItem temp;
				temp.name = words[1].str;
				temp.type = 'b';

				size_t start = line.find("[", 0);
				size_t end = line.find("]", 0);
				if (start == std::string::npos || end == std::string::npos){
					err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Failed to find square brackets.";
					return false;
				}

				std::string mat_str = line.substr(start+1, end-start-1);

				try{
					temp.mb = gstd::to_bvec(mat_str);
				}catch(...){
					err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Failed to interpret '" + mat_str + "' as a matrix of booleans.";
					return false;
				}

				//Find where data ends, optional features begin
				optional_features_start = 4;
				for (; optional_features_start < words.size() ; optional_features_start++){
					if (words[optional_features_start].idx > end){
						break;
					}
				}

				//Read optional arguments/features
				bool allow_semi = true;
				bool in_desc = false;
				for (size_t i = optional_features_start ; i < words.size() ; i++){

					if (words[i].str == ";"){
						if (!allow_semi){
							err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Detected excessive semicolons.";
							return false;
						}
						allow_semi = false;
					}else if(words[i].str == "?" || (words[i].str.length() > 0 && words[i].str[0] == '?')){
						in_desc = true;
						temp.description = line.substr(words[i].idx+1); //The description is the string of characters starting immediately after the questionmark
					}else if(words[i].str == "//"){
						break; //the rest is a comment - exit loop
					}

				}

				variables1D.push_back(temp);

			}else if(words[0].str == "m<s>" && !is_2d(line)){ //String matrix 1D

				DDF1DItem temp;
				temp.name = words[1].str;
				temp.type = 's';

				size_t start = line.find("[", 0);
				size_t end = line.find("]", 0);
				if (start == std::string::npos || end == std::string::npos){
					err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Failed to find square brackets.";
					return false;
				}

				std::string mat_str = line.substr(start+1, end-start-1);

				try{
					temp.ms = gstd::to_svec(mat_str);
				}catch(...){
					err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Failed to interpret '" + mat_str + "' as a matrix of strings.";
					return false;
				}

				//Find where data ends, optional features begin
				optional_features_start = 4;
				for (; optional_features_start < words.size() ; optional_features_start++){
					if (words[optional_features_start].idx > end){
						break;
					}
				}

				//Read optional arguments/features
				bool allow_semi = true;
				bool in_desc = false;
				for (size_t i = optional_features_start ; i < words.size() ; i++){

					if (words[i].str == ";"){
						if (!allow_semi){
							err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Detected excessive semicolons.";
							return false;
						}
						allow_semi = false;
					}else if(words[i].str == "?" || (words[i].str.length() > 0 && words[i].str[0] == '?')){
						in_desc = true;
						temp.description = line.substr(words[i].idx+1); //The description is the string of characters starting immediately after the questionmark
					}else if(words[i].str == "//"){
						break; //the rest is a comment - exit loop
					}

				}

				variables1D.push_back(temp);

			}else if(words[0].str == "m<d>"){ //Double matrix 2D

				DDF2DItem temp;
				temp.name = words[1].str;
				temp.type = 'd';

				size_t start = line.find("[", 0);
				size_t end = line.find("]", 0);
				if (start == std::string::npos || end == std::string::npos){
					err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Failed to find square brackets.";
					return false;
				}

				std::string mat_str = line.substr(start+1, end-start-1);
				try{
					temp.md2 = gstd::to_dvec2D(mat_str);
				}catch(...){
					err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Failed to interpret '" + mat_str + "' as a 2D matrix of doubles.";
					return false;
				}

				//Find where data ends, optional features begin
				optional_features_start = 4;
				for (; optional_features_start < words.size() ; optional_features_start++){
					if (words[optional_features_start].idx > end){
						break;
					}
				}


				//Read optional arguments/features
				bool allow_semi = true;
				bool in_desc = false;
				for (size_t i = optional_features_start ; i < words.size() ; i++){

					if (words[i].str == ";"){
						if (!allow_semi){
							err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Detected excessive semicolons.";
							return false;
						}
						allow_semi = false;
					}else if(words[i].str == "?" || (words[i].str.length() > 0 && words[i].str[0] == '?')){
						in_desc = true;
						temp.description = line.substr(words[i].idx+1); //The description is the string of characters starting immediately after the questionmark
					}else if(words[i].str == "//"){
						break; //the rest is a comment - exit loop
					}

				}

				variables2D.push_back(temp);

			}else if(words[0].str == "m<b>"){ //Bool matrix 2D

				DDF2DItem temp;
				temp.name = words[1].str;
				temp.type = 'b';

				size_t start = line.find("[", 0);
				size_t end = line.find("]", 0);
				if (start == std::string::npos || end == std::string::npos){
					err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Failed to find square brackets.";
					return false;
				}

				std::string mat_str = line.substr(start+1, end-start-1);

				try{
					temp.mb2 = gstd::to_bvec2D(mat_str);
				}catch(...){
					err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Failed to interpret '" + mat_str + "' as a 2D matrix of booleans.";
					return false;
				}

				//Find where data ends, optional features begin
				optional_features_start = 4;
				for (; optional_features_start < words.size() ; optional_features_start++){
					if (words[optional_features_start].idx > end){
						break;
					}
				}

				//Read optional arguments/features
				bool allow_semi = true;
				bool in_desc = false;
				for (size_t i = optional_features_start ; i < words.size() ; i++){

					if (words[i].str == ";"){
						if (!allow_semi){
							err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Detected excessive semicolons.";
							return false;
						}
						allow_semi = false;
					}else if(words[i].str == "?" || (words[i].str.length() > 0 && words[i].str[0] == '?')){
						in_desc = true;
						temp.description = line.substr(words[i].idx+1); //The description is the string of characters starting immediately after the questionmark
					}else if(words[i].str == "//"){
						break; //the rest is a comment - exit loop
					}

				}

				variables2D.push_back(temp);

			}else if(words[0].str == "m<s>"){ //String matrix 2D

				DDF2DItem temp;
				temp.name = words[1].str;
				temp.type = 's';

				size_t start = line.find("[", 0);
				size_t end = line.find("]", 0);
				if (start == std::string::npos || end == std::string::npos){
					err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Failed to find square brackets.";
					return false;
				}

				std::string mat_str = line.substr(start+1, end-start-1);

				try{
					temp.ms2 = gstd::to_svec2D(mat_str);
				}catch(...){
					err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Failed to interpret '" + mat_str + "' as a 2D matrix of strings.";
					return false;
				}

				//Find where data ends, optional features begin
				optional_features_start = 4;
				for (; optional_features_start < words.size() ; optional_features_start++){
					if (words[optional_features_start].idx > end){
						break;
					}
				}

				//Read optional arguments/features
				bool allow_semi = true;
				bool in_desc = false;
				for (size_t i = optional_features_start ; i < words.size() ; i++){

					if (words[i].str == ";"){
						if (!allow_semi){
							err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tFor variable '" + words[1].str + "': Detected excessive semicolons.";
							return false;
						}
						allow_semi = false;
					}else if(words[i].str == "?" || (words[i].str.length() > 0 && words[i].str[0] == '?')){
						in_desc = true;
						temp.description = line.substr(words[i].idx+1); //The description is the string of characters starting immediately after the questionmark
					}else if(words[i].str == "//"){
						break; //the rest is a comment - exit loop
					}

				}

				variables2D.push_back(temp);
			}

		}else if(words[0].str == "#VERTICAL"){

			std::vector<std::string> vert_block; //Clear header
			std::vector<size_t> line_nums;
			size_t openedOnLine = lineNum;

			bool foundBlock = false;
			while (getline(file, line)){ //Keep reading lines until closing vert block found

				lineNum++;

				//Break line into words...
				std::vector<gstd::string_idx> words = gstd::parseIdx(line, " \t", ";");

				if (words.size() < 1) continue; //Skip blank lines

				if (words[0].str.length() >= 2 && words[0].str.substr(0, 2) == "//") continue; //Skip comments TODO: Change comment removal to occur in pass through at beginning of read

				if(words[0].str == "#VERTICAL"){ //Is a closing block statement
					foundBlock = true;
					break;
				}else{ //Is part of the block...

					//Trim inline comments
					std::string comment_trimmed_line = line;
					for (size_t l = 1 ; l+1 < line.length() ; l++){ //Can't be first character - comments starting with first character were removed along with blank lines
						if (line.substr(l, 2) == "//"){
							comment_trimmed_line = line.substr(0, l);
						}
					}

					//Push line w/ comment removed back
					vert_block.push_back(comment_trimmed_line);
					line_nums.push_back(lineNum);

				}

			}

			//Ensure end of file was not reached before header found
			if (!foundBlock){
				err_str = "Failed on line " + std::to_string(openedOnLine) + ".\n\tFailed to find closing #VERTICAL statement.";
				return false;
			}

			//The vertical block has now been read into vert_block vector - time to process it further...

			if (vert_block.size() < 3){
				err_str = "Failed in vertical block beginning on line " + std::to_string(openedOnLine) + ".\n\tFound fewer than three non-blank lines.";
				return false;
			}

			std::vector<std::string> types = gstd::parse(vert_block[0], " \t"); //Read variable types from first line
			std::vector<std::string> names = gstd::parse(vert_block[1], " \t"); //Read variable names from 2nd line
			std::vector<std::string> descs;

			//Check if descriptions are present
			std::string desc_line = vert_block[2];
			gstd::trim_whitespace(vert_block[2]); //Remove whitespace from start + end, '?' must be first char if desc line
			if (desc_line.length() >= 1 && desc_line[0] == '?'){

				//Read description line
				descs = gstd::parse(vert_block[2], "?"); //Read descriptions from 3rd line
				for (size_t e = 0 ; e < descs.size() ; e++){ //Remove trailing whitespace from descriptions
					gstd::trim_whitespace(descs[e]);
				}

			}

			//Check for errors in type, name, or quantities
			if (types.size() != names.size() || (descs.size() > 0 && descs.size() != types.size())){ //Check that types, names, and descs (if present) are the same size
				err_str = "Failed on line " + std::to_string(line_nums[0]) + ".\n\tNumber of type declarations, names, and descriptions (if present) must match.";
				return false;
			}

			//For each variable name & type...
			for (size_t i = 0 ; i < names.size() ; i++){

				//Ensure variable name is valid
				if (!isValidName(names[i])){
					err_str = "Failed on line " + std::to_string(line_nums[1]) + ".\n\tVariable name '" + names[i] + "' is invalid.";
					return false;
				}

				//Ensure type is valid
				if (types[i] != "m<d>" && types[i] != "m<s>" && types[i] != "m<b>"){
					err_str = "Failed on line " + std::to_string(line_nums[0]) + ".\n\tType '" + types[i] + "' is invalid.";
					return false;
				}
			}

			//Initialize the 2D vector of string data contents for each matrix detected
			std::vector<std::vector<std::string> > data_str;
			std::vector<bool> is_2dmat;
			for (size_t i = 0 ; i < names.size() ; i++){
				std::vector<std::string> temp_vs;
				data_str.push_back(temp_vs);
				is_2dmat.push_back(false);
			}


			//Go through data line by line and add contents to string vectors
			std::vector<std::string> words;
			size_t max_allowed = names.size();
			size_t l = 2;
			if (descs.size() > 0) l++;
			for (; l < vert_block.size() ; l++){

				words = gstd::parse(vert_block[l], " \t", "", true); //Parse tokens via whitespace, but preserve strings as one token

				//Check that a matrix didn't omit data one line, then bring it back the next
				if (words.size() > max_allowed){
					err_str = "Failed on line " + std::to_string(line_nums[l]) + ".\n\tToo many characters detected.";
					return false;
				}

				//Update maximum No. allowed tokens
				if (words.size() < max_allowed) max_allowed = words.size();

				//For each token, add to corresponding string data vector
				for (size_t i = 0 ; i < words.size() ; i++){
					data_str[i].push_back(words[i]);
					if (words[i][words[i].length()-1] == ';'){
						is_2dmat[i] = true;
					}
				}

			}

			//Create variable struct
			for (size_t i = 0 ; i < names.size() ; i++){
				if (is_2dmat[i]){

					DDF2DItem temp;
					std::vector<double> td;
					std::vector<bool> tb;
					std::vector<std::string> ts;

					if (types[i] == "m<d>"){
						temp.type = 'd';
					}else if(types[i] == "m<s>"){
						temp.type = 's';
					}else{ //bool
						temp.type = 'b';
					}

					temp.name = names[i];

					if (descs.size() > 0){
						temp.description = descs[i];
					}

					//For each line of data for this variable...
					for (size_t k = 0 ; k < data_str[i].size() ; k++){


						//Check if marks end of row
						bool row_end = false;
						std::string data_str_wo_semicolon = data_str[i][k];
						if (data_str[i][k][data_str[i][k].length()-1] == ';'){
							row_end = true;
							data_str_wo_semicolon = data_str[i][k].substr(0, data_str[i][k].length()-1); //Remove semicolon so it doesnt mess up data conversion
						}

						//Translate data string and save into DDF-item
						if (types[i] == "m<d>"){
							try{
								td.push_back(stod(data_str_wo_semicolon));
							 }catch(...){
								err_str = "Failed on line " + std::to_string(line_nums[l]) + ".\n\tFailed to convert '" + data_str_wo_semicolon + "' to a double.";
								return false;
							}
							if (row_end){
								temp.md2.push_back(td);
								td.clear();
							}
						}else if(types[i] == "m<s>"){
							size_t pos;
							ts.push_back(gstd::get_string(data_str_wo_semicolon, pos));
							if (row_end){
								temp.ms2.push_back(ts);
								ts.clear();
							}
						}else{ //bool
							tb.push_back( gstd::to_bool(data_str_wo_semicolon) );

							if (row_end){
								temp.mb2.push_back(tb);
								tb.clear();
							}
						}
					}

					//Add last row...
					if (types[i] == "m<d>" && td.size() > 0){
						temp.md2.push_back(td);
					}else if(types[i] == "m<s>" && ts.size() > 0){
						temp.ms2.push_back(ts);
					}else if(types[i] == "m<b>" && tb.size() > 0){
						temp.mb2.push_back(tb);
					}

					variables2D.push_back(temp);

				}else{

					DDF1DItem temp;

					if (types[i] == "m<d>"){
						temp.type = 'd';
					}else if(types[i] == "m<s>"){
						temp.type = 's';
					}else{ //bool
						temp.type = 'b';
					}

					temp.name = names[i];

					if (descs.size() > 0){
						temp.description = descs[i];
					}

					//For each line of data for this variable...
					for (size_t k = 0 ; k < data_str[i].size() ; k++){
						if (types[i] == "m<d>"){
							try{
								temp.md.push_back(stod(data_str[i][k]));
							 }catch(...){
								err_str = "Failed on line " + std::to_string(line_nums[l]) + ".\n\tFailed to convert '" + data_str[i][k] + "' to a double.";
								return false;
							}
						}else if(types[i] == "m<s>"){
							size_t pos;
							temp.ms.push_back(gstd::get_string(data_str[i][k], pos));
						}else{ //bool
							temp.mb.push_back( gstd::to_bool(data_str[i][k]) );
						}
					}

					variables1D.push_back(temp);
				}

			}



		}else{
			err_str = "Failed on line " + std::to_string(lineNum) + ".\n\tUnidentified token '" + words[0].str + "'";
			return false;
		}



	}

	return true;
}

bool DDFIO::clload(std::string fileIn){
	clear();
	return load(fileIn);
}



//***************************************************************************//
//*************** VARIABLE MANAGEMENT

bool DDFIO::checkContains(std::vector<std::string> names){ //TODO: impliment checkContains()
	std::cout << "Oops! Need to impliment this :)" << std::endl;
	return false;
}

/*
Clears all variables from the DDFIO object.
*/
void DDFIO::clear(){
	fileVersion = -1;
	header = "";
	variablesFlat.clear();
	variables1D.clear();
	variables2D.clear();
}

/*
Returns the number of variables of all types combined that are presently loaded
in this DDFIO object.
*/
size_t DDFIO::numVar(){
	return variablesFlat.size() + variables1D.size() + variables2D.size();
}

//***************************************************************************//
//*************** HEADER

/*
Sets the header
*/
void DDFIO::setHeader(std::string h){
	header = h;
}

/*
Returns the header
*/
std::string DDFIO::getHeader(){
	return header;
}

/*
Returns the file's verion.
*/
double DDFIO::getVersion(){
	return fileVersion;
}

/*
Returns the error status
*/
std::string DDFIO::err(){
	return err_str;
}

//***************************************************************************//
//*************** PRINTING

/*
Returns a vector of strings of the variables' names.

Options:
	- t: include variable type with name
	- m: merge all names into one string, save in returned vector's index 0.
*/
std::vector<std::string> DDFIO::names(std::string options){

	//Options
	bool include_type = false;
	bool merge = false;

	//Read in options
	if (options.find("t", 0) != std::string::npos){
		include_type = true;
	}
	if (options.find("m", 0) != std::string::npos){
		merge = true;
	}

	std::vector<std::string> names_out;

	//Add flat names
	for (size_t i = 0 ; i < variablesFlat.size() ; i++){
		if (include_type){
			names_out.push_back(variablesFlat[i].name + " (" + variablesFlat[i].type + ")");
		}else{
			names_out.push_back(variablesFlat[i].name);
		}
	}

	//Add 1D names
	for (size_t i = 0 ; i < variables1D.size() ; i++){
		if (include_type){
			names_out.push_back(variables1D[i].name + " (m<" + variables1D[i].type + ">)");
		}else{
			names_out.push_back(variables1D[i].name);
		}
	}

	//Add 2D names
	for (size_t i = 0 ; i < variables2D.size() ; i++){
		if (include_type){
			names_out.push_back(variables2D[i].name + " (m<" + variables2D[i].type + ">(2D))");
		}else{
			names_out.push_back(variables2D[i].name);
		}
	}

	//Merge (if requested)
	if (merge){

		std::string merged_str = ""; //Create blank string

		//For each name...
		for (size_t i = 0 ; i+1 < names_out.size() ; i++){
			merged_str = merged_str + names_out[i] + ", "; //Add to merged name...
		}

		//Add last element without comma
		if (names_out.size() > 0){
			merged_str = merged_str + names_out[names_out.size()-1];
		}

		names_out.clear(); //Clear output vector
		names_out.push_back(merged_str); //push back merged string
	}

	//Return names vector
	return names_out;

}

/*
Returns the contents of the DDFIO object as a string.
*/
std::string DDFIO::show(){

	std::string out = "";

	out = "No. Variables: " + std::to_string(numVar());
	out = out + "\nFlat Variables:\n";

	size_t trim_len = 45;

	if (variablesFlat.size() > 0){
		KTable flat_vars;
		flat_vars.table_title("Flat Variables");
		flat_vars.row({"Name", "Type", "Value", "Description"});
		for (size_t i = 0 ; i < variablesFlat.size() ; i++){

			std::string typecode = "";
			std::string valstr = "";
			switch (variablesFlat[i].type){
				case('d'):
					typecode = "double";
					valstr = std::to_string(variablesFlat[i].d);
					break;
				case('s'):
					typecode = "string";
					valstr = variablesFlat[i].s;
					break;
				case('b'):
					typecode = "bool";
					valstr = bool_to_string(variablesFlat[i].b);
					break;
				default:
					typecode = "?";
					valstr = "?";
					break;
			}

			flat_vars.row({variablesFlat[i].name, typecode, valstr, variablesFlat[i].description});

		}

		flat_vars.alignt('l');
		flat_vars.alignh('l');
		flat_vars.alignc('l');
		flat_vars.alignc(3, 'l');
		flat_vars.trimc('c', trim_len);
		out = out + flat_vars.str();
	}

	if (variables1D.size() > 0){
		KTable m1d_vars;
		m1d_vars.table_title("1D Variables");
		m1d_vars.row({"Name", "Type", "Value", "Description"});
		for (size_t i = 0 ; i < variables1D.size() ; i++){

			size_t k;
			std::string typecode = "";
			std::string val_str = "[";
			switch (variables1D[i].type){
				case('d'):
					typecode = "m<double>";
					for (k = 0 ; k < variables1D[i].md.size()-1 ; k++){
						val_str = val_str + gstd::to_gstring(variables1D[i].md[k]) + ", ";
					}
					val_str = val_str + gstd::to_gstring(variables1D[i].md[k]);
					break;
				case('s'):
					typecode = "m<string>";
					for (k = 0 ; k < variables1D[i].ms.size()-1 ; k++){
						val_str = val_str + "\"" + (variables1D[i].ms[k]) + "\", ";
					}
					val_str = val_str + "\"" + (variables1D[i].ms[k]) + "\"";
					break;
				case('b'):
					typecode = "m<bool>";
					for (k = 0 ; k < variables1D[i].mb.size()-1 ; k++){
						val_str = val_str + bool_to_string(variables1D[i].mb[k]) + ", ";
					}
					val_str = val_str + bool_to_string(variables1D[i].mb[k]);
					break;
				default:
					typecode = "?";
					val_str = "?";
					break;
			}
			val_str = val_str + "]";

			m1d_vars.row({variables1D[i].name, typecode, val_str, variables1D[i].description});

		}

		m1d_vars.alignt('l');
		m1d_vars.alignh('l');
		m1d_vars.alignc('l');
		m1d_vars.alignc(3, 'l');
		m1d_vars.trimc('c', trim_len);
		out = out + m1d_vars.str();
	}

	if (variables2D.size() > 0){
		KTable m2d_vars;
		m2d_vars.table_title("2D Variables");
		m2d_vars.row({"Name", "Type", "Value", "Description"});
		for (size_t i = 0 ; i < variables2D.size() ; i++){

			size_t k,j;
			std::string typecode = "";
			std::string val_str = "";
			switch (variables2D[i].type){
				case('d'):
					typecode = "double";
					for (k = 0 ; k < variables2D[i].md2.size()-1 ; k++){
						for (j = 0 ; j < variables2D[i].md2[k].size()-1 ; j++){
							val_str = val_str + gstd::to_gstring(variables2D[i].md2[k][j]) + ", ";
						}
						val_str = val_str + gstd::to_gstring(variables2D[i].md2[k][j]) + " ; ";
					}
					for (j = 0 ; j < variables2D[i].md2[k].size()-1 ; j++){
						val_str = val_str + gstd::to_gstring(variables2D[i].md2[k][j]) + ", ";
					}
					val_str = val_str + gstd::to_gstring(variables2D[i].md2[k][j]);
					// valstr = std::to_string(variables2D[i].d);
					break;
				case('s'):
					typecode = "string";
					for (k = 0 ; k < variables2D[i].ms2.size()-1 ; k++){
						for (j = 0 ; j < variables2D[i].ms2[k].size()-1 ; j++){
							val_str = val_str + "\"" + (variables2D[i].ms2[k][j]) + "\", ";
						}
						val_str = val_str + "\"" + (variables2D[i].ms2[k][j]) + "\" ; ";
					}
					for (j = 0 ; j < variables2D[i].ms2[k].size()-1 ; j++){
						val_str = val_str + "\"" + (variables2D[i].ms2[k][j]) + "\", ";
					}
					val_str = val_str + "\"" + (variables2D[i].ms2[k][j]) + "\"";
					break;
				case('b'):
					typecode = "bool";
					for (k = 0 ; k < variables2D[i].mb2.size()-1 ; k++){
						for (j = 0 ; j < variables2D[i].mb2[k].size()-1 ; j++){
							val_str = val_str + bool_to_string(variables2D[i].mb2[k][j]) + ", ";
						}
						val_str = val_str + bool_to_string(variables2D[i].mb2[k][j]) + " ; ";
					}
					for (j = 0 ; j < variables2D[i].mb2[k].size()-1 ; j++){
						val_str = val_str + bool_to_string(variables2D[i].mb2[k][j]) + ", ";
					}
					val_str = val_str + bool_to_string(variables2D[i].mb2[k][j]);
					break;
				default:
					typecode = "?";
					val_str = "?";
					break;
			}

			m2d_vars.row({variables2D[i].name, typecode, val_str, variables2D[i].description});

		}

		m2d_vars.alignt('l');
		m2d_vars.alignh('l');
		m2d_vars.alignc('l');
		m2d_vars.alignc(3, 'l');
		m2d_vars.trimc('c', trim_len);
		out = out + m2d_vars.str();
	}

	return out;
}

//***************************************************************************//
//**			PRIVATE FUNCTION DEFINITIONS							   **//
//***************************************************************************//

/*
Verifies that the proposed variable name is a valid variable name.

Returns true if the name is valid.
*/
bool DDFIO::isValidName(std::string name){

	//Ensure name is at least 1 character
	if (name.length() < 1){
		return false;
	}

	//Make sure name starts with a letter
	if (!isalpha(name[0])){
		return false;
	}

	//For each character...
	for (size_t i = 0 ; i < name.length() ; i++){

		//Check if it is whitespace...
		if (isspace(name[i]) == 1){
			return false;
		}
	}

	return true;
}

/*
Checks if the variable name is already in use. Returns true if in use.
*/
bool DDFIO::nameInUse(std::string name){

	//Check flat variables...
	for (size_t i = 0 ; i < variablesFlat.size() ; i++){
		if (variablesFlat[i].name == name) return true;
	}

	//Check 1D variables...
	for (size_t i = 0 ; i < variables1D.size() ; i++){
		if (variables1D[i].name == name) return true;
	}

	//Check 2D variables...
	for (size_t i = 0 ; i < variables2D.size() ; i++){
		if (variables2D[i].name == name) return true;
	}

	return false;
}

/*
Sorts the 1D and 2D matrices from largest to smallest.
*/
void DDFIO::sortMatrices(){

	//Sort 1D vector
	for (size_t i = 1 ; i < variables1D.size() ; i++){ //For each matrix (skipping first) ...

		//Get length
		size_t el = matrixLength(variables1D[i]);

		size_t j = i-1; //Get position to compare against
		while (el > matrixLength(variables1D[j])){ //Keep checking new indeces until you find a larger or equal size matrix

			//The current matrix is larger than the previous matrix...

			if (j > 0){ //If possible, move compare index closer to 0
				j--;
			}else{ //Else break - you're at the beginning
				break;
			}
		}

		//Move matrix if required
		if (j+1 == i){
			DDF1DItem temp = variables1D[i]; //Make a copy of the current matrix

			variables1D.erase(variables1D.begin() + i); 			//Erase at old location
			variables1D.insert(variables1D.begin() + j+1, temp);	//Insert into new location
		}

	}

	//Sort 2D vector
	for (size_t i = 1 ; i < variables2D.size() ; i++){ //For each matrix (skipping first) ...

		//Get length
		size_t el = matrixLength(variables2D[i]);

		size_t j = i-1; //Get position to compare against
		while (el > matrixLength(variables2D[j])){ //Keep checking new indeces until you find a larger or equal size matrix

			//The current matrix is larger than the previous matrix...

			if (j > 0){ //If possible, move compare index closer to 0
				j--;
			}else{ //Else break - you're at the beginning
				break;
			}
		}

		//Move matrix if required
		if (j+1 == i){
			DDF2DItem temp = variables2D[i]; //Make a copy of the current matrix

			variables2D.erase(variables2D.begin() + i); 			//Erase at old location
			variables2D.insert(variables2D.begin() + j+1, temp);	//Insert into new location
		}

	}

}

/*
Calculates the total number of elements in the DDFItem and returns it.
*/
size_t DDFIO::matrixLength(DDF1DItem m){

	switch(m.type){
		case('d'):
			return m.md.size();
			break;
		case('s'):
			return m.ms.size();
			break;
		case('b'):
			return m.mb.size();
			break;
		default:
			return 0;
			break;
	}
}

/*
Calculates the total number of elements (in all rows and cols, combined) in the
DDFItem and returns it.
*/
size_t DDFIO::matrixLength(DDF2DItem m){

	size_t l;

	switch(m.type){
		case('d'):

			l = 0;
			for (size_t j = 0 ; j < m.md2.size() ; j++){ //For each row...
				l += m.md2[j].size(); //Get size, increment sum
			}

			return l; //Return sum

			break;
		case('s'):

			l = 0;
			for (size_t j = 0 ; j < m.ms2.size() ; j++){ //For each row...
				l += m.ms2[j].size(); //Get size, increment sum
			}

			return l; //Return sum

			break;
		case('b'):

			l = 0;
			for (size_t j = 0 ; j < m.mb2.size() ; j++){ //For each row...
				l += m.mb2[j].size(); //Get size, increment sum
			}

			return l; //Return sum

			break;
		default:
			return 0;
			break;
	}

}

/*
Finds the 'idx'th variable in m, acting as if each lower row is appended to the
end of the preceeding row. Makes 2D vector look 1D in terms of indexing.

Returns 'idx'-th value in 'm'. Returns -1 if idx out of range.
*/
double DDFIO::linaccess(std::vector<std::vector<double> > m, size_t idx){

	size_t count = 0;

	for (size_t r = 0 ; r < m.size() ; r++){
		if (m[r].size() + count > idx){
			return m[r][idx - count];
		}else{
			count += m[r].size();
		}
	}

	return -1; //Default return if out of bounds
}

/*
Finds the 'idx'th variable in m, acting as if each lower row is appended to the
end of the preceeding row. Makes 2D vector look 1D in terms of indexing.

Returns 'idx'-th value in 'm'. Returns false if idx out of range.
*/
bool DDFIO::linaccess(std::vector<std::vector<bool> > m, size_t idx){

	size_t count = 0;

	for (size_t r = 0 ; r < m.size() ; r++){
		if (m[r].size() + count > idx){
			return m[r][idx - count];
		}else{
			count += m[r].size();
		}
	}

	return ""; //Default false if out of bounds
}

/*
Finds the 'idx'th variable in m, acting as if each lower row is appended to the
end of the preceeding row. Makes 2D vector look 1D in terms of indexing.

Returns 'idx'-th value in 'm'. Returns blank if idx out of range.
*/
std::string DDFIO::linaccess(std::vector<std::vector<std::string> > m, size_t idx){

	size_t count = 0;

	for (size_t r = 0 ; r < m.size() ; r++){
		if (m[r].size() + count > idx){
			return m[r][idx - count];
		}else{
			count += m[r].size();
		}
	}

	return ""; //Default return if out of bounds
}

/*
Treats a 2D matrix as 1D, pretending each row is appended to the preceeding row.
Returns true if the element at index 'idx' is actually the end of a row in the
real 2D matrix.

Also returns false if idx is out of bounds, or if any other error occurs.
*/
bool DDFIO::isRowEnd(DDF2DItem m, size_t idx){

	size_t count = 0;

	switch(m.type){
		case('d'):
			for (size_t r = 0 ; r < m.md2.size() ; r++){
				if (m.md2[r].size() + count > idx){
					return (idx == (count + m.md2[r].size()-1));
				}else{
					count += m.md2[r].size();
				}
			}
			break;
		case('b'):
			for (size_t r = 0 ; r < m.mb2.size() ; r++){
				if (m.mb2[r].size() + count > idx){
					return (idx == (count + m.mb2[r].size()-1));
				}else{
					count += m.mb2[r].size();
				}
			}
			break;
		case('s'):
			for (size_t r = 0 ; r < m.ms2.size() ; r++){
				if (m.ms2[r].size() + count > idx){
					return (idx == (count + m.ms2[r].size()-1));
				}else{
					count += m.ms2[r].size();
				}
			}
			break;
		default:
			return false;
	}

	return false; //Default return if out of bounds

}

/*
Initializes the KTable for use in generating vertical DDF matrix statements.
*/
void DDFIO::init_ktable(KTable& kt){

	kt.table_title("");
	kt.set(KTABLE_INTERWALLS, false);
	kt.set(KTABLE_SIDEWALLS, false);
	kt.set(KTABLE_TOPBOTTOMHBAR, false);
	kt.set(KTABLE_HEADERINTERWALLS, false);
	kt.set(KTABLE_HEADERHBAR, false);
	kt.set(KTABLE_TITLEHBAR, false);
	// kt.set(KTABLE_TITLEBAR, false); //TODO: KTable bug - if I turn title off, can't surpress preceeding ----s and on same line :\
	// kt.set(KTABLE_INTERHBARS, false);
	kt.alignh('l');
	kt.alignc('l');
	kt.alignt('l');

}

//***************************************************************************//
//**			NON-CLASS FUNCTION DEFINITIONS							   **//
//***************************************************************************//



std::string bool_to_string(bool b){
	return b? "true" : "false";
}

/*
Accepts a string from a DDF inline variable statement and determines if it represents
a 2D matrix by seeing if a semicolon appears before a closing square bracket.
*/
bool is_2d(std::string line){

	//Find end brackets, find first semicolon
	size_t end = line.find("]", 0);
	size_t first_semi = line.find(";", 0);

	//Not 2D matrix if no brackets or no semicolon
	if (first_semi == std::string::npos || end == std::string::npos){
		return false;
	}

	return (first_semi < end);
}

#endif
