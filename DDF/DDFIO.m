classdef DDFIO < handle
% DDFIO Read and write DDF files.
%	Reads and writes the DDF data file format.
%
% DDFIO Properties:
%	varsFlat - Matrix of DDFItems representing non-matrix variables
%	vars1D - Matrix of DDFItems representing 1D matrix variables
%	vars2D - Matrix of DDFItems representing 2D matrix variables
%	header - header string either read from file, or to be written to file
%	fileVersion - version number of last read file
%
% DDFIO Methods:
%	add - Add a variable to the DDFIO
%	assignAll - Assigns all variables loaded in the DDF file to the workspace
%	get - Returns the DDFItem with the specified name
%	checkContains - Checks that a variable exists with the specified name
%	the DDFIO object.
%	err - Display and erase the most recent error message
%	numVar - Return the number of varaibles loaded in the DDFIO object
%	clear - Clear all contents of the DDFIO object
%	getHeader - Return the header string
%	setHeader - Set the header string
%	show - Display all contents of the DDFIO object
%	write - Write the contents of the DDFIO object to a DDF file
%	swrite - Write the contents of the DDFIO object to a DDF formatted string
%	loadDDF_V1 - Read a version 1 DDF file
%

% TODO: Prevent names with spaces from being allowed

	properties   %************************ PROPERTIES *********************
		varsFlat
		vars1D
		vars2D
		header
		fileVersion
	end   %********************** END PROPERTIES **************************

	properties (Access=private) %************ PRIVATE PROPERTIES **********
		error_messages
		current_version
		current_version_str
	end  %********************* END PRIVATE PROPERTIES ********************

	methods   %************************ METHODS ***************************

		function obj=DDFIO(varargin)	%*************** INITIALIZER **************
			obj.varsFlat = [];
			obj.vars1D = [];
			obj.vars2D = [];
			obj.header = "";
			obj.fileVersion = -1;
			obj.error_messages = [];
			obj.current_version = 1;
			obj.current_version_str = "1.0";

			if nargin > 0
				if class(varargin{1}) == "string"
					obj.loadDDF_V1(varargin{1});
				end
			end
		end %******************************* END INITIALIZER **************

		function add(obj, newVar, varName, desc) %******** add() **********

			%Create new DDF Item
			newItem = DDFItem(newVar, varName, desc);

			%Verify variable not already in object
			if obj.checkContains(varName)
				obj.logErr(strcat("Failed to add variable '", varName, "' because a variable with it's name already exists"));
				return;
			end

			%Find correct group to add to
			if newItem.dimension == 1
				if length(obj.varsFlat) == 0
					obj.varsFlat = newItem;
				else
					obj.varsFlat(end+1) = newItem;
				end
			elseif newItem.dimension == 2
				if length(obj.vars1D) == 0
					obj.vars1D = newItem;
				else
					obj.vars1D(end+1) = newItem;
				end
			elseif newItem.dimension == 3
				if length(obj.vars2D) == 0
					obj.vars2D = newItem;
				else
					obj.vars2D(end+1) = newItem;
				end
			else
				obj.logErr(strcat("Dimension exceeded 2D (d=", num2str(newItem.dimension) , ") - failed to add '", varName, "'"));
				return;
			end

		end %*********************************** END add() ****************

		function assignAll(obj) %**************** assignAll() *************

			for ddfi=obj.varsFlat
				assignin('base', ddfi.name, ddfi.val);
			end
			for ddfi=obj.vars1D
				assignin('base', ddfi.name, ddfi.val);
			end
			for ddfi=obj.vars2D
				assignin('base', ddfi.name, ddfi.val);
			end

		end %******************* END assignAll() **************************

		function di=get(obj, name) %************* get() *******************

			for ddfi=obj.varsFlat
				if ddfi.name == name
					di=ddfi;
					return;
				end
			end
			for ddfi=obj.vars1D
				if ddfi.name == name
					di=ddfi;
					return;
				end
			end
			for ddfi=obj.vars2D
				if ddfi.name == name
					di=ddfi;
					return;
				end
			end

			%TODO: Return empty instead?
			nki = DDFItem(-1, "NOTFOUND", "");
			nki.isnotfound = true;
			di=nki;
		end %******************************* END get() ********************

		function isHere=checkContains(obj, name) %***** checkContains() ***
			for ddfi=obj.varsFlat
				if ddfi.name == name
					isHere = true;
					return;
				end
			end
			for ddfi=obj.vars1D
				if ddfi.name == name
					isHere = true;
					return;
				end
			end
			for ddfi=obj.vars2D
				if ddfi.name == name
					isHere = true;
					return;
				end
			end

			isHere = false;
		end %********************* END checkContains() ********************

		function logErr(obj, msg) %************** logErr() ****************
			if length(obj.error_messages) == 0
				obj.error_messages = strcat("ERROR: ", msg);
				return;
			end
			obj.error_messages(end+1) = strcat("ERROR: ", msg);
		end %****************************** END logErr() ******************

		function logErrLn(obj, msg, lnum) %************** logErrLn() ******

			err_msg = strcat("(line ", string(lnum), ") ", msg);
			obj.logErr(err_msg);

		end %**************************** END logErrLn() ******************

		function strout=err(obj) %********************** err() ************
			if length(obj.error_messages) == 0
				strout = "No errors";
				return;
			end
			strout=obj.error_messages(end);
			obj.error_messages(end) = [];
		end %************************************* END err() **************

		function n=numVar(obj) %**************** numVar() *****************

			n = length(obj.varsFlat) + length(obj.vars1D) + length(obj.vars2D);

		end %************************ END numVar() ************************

		function clear(obj) %******************* clear() ******************
			obj.varsFlat = [];
			obj.vars1D = [];
			obj.vars2D = [];
			obj.error_messages = [];
			obj.header = "";
			obj.fileVersion = -1;
		end %*************************** END clear() **********************

		function hdr=getHeader(obj) %************* getHeader() ************
			hdr = obj.header;
		end %*********************************** END getHeader() **********

		function setHeader(obj, hstr) %********** setHeader() *************
			obj.header = hstr;
		end %*************************** END setHeader() ******************

		function valid=isValidName(obj, name) %********** isValidName() *********

			%Convert to character array
			name = char(name);

			%Ensure name is at least 1 character
			if name == ""
				valid=false;
				return;
			end

			%For each character
			if ~all(isstrprop(name, "alphanum") | name == '_')
				valid = false;
				return;
			end

			%Check that first character is letter
			if ~isletter(name(1)) && name(1) ~= '_'
				valid=false;
				return;
			end




			valid=true;
			return;

		end %*************************** END isValidName() ****************

		function sortMatrices(obj) %********* sortMatrices() **************

			for v = obj.vars1D
				v.updateCount();
			end
			
			for v = obj.vars2D
				v.updateCount();
			end
			
			%For 1D vectors
			if length(obj.vars1D) > 1
				[~, ind] = sort([obj.vars1D.count], 'descend');
				obj.vars1D = obj.vars1D(ind);
			end

			%For 2D vectors
			if length(obj.vars2D) > 2
				[~, ind] = sort([obj.vars2D.count], 'descend');
				obj.vars2D = obj.vars2D(ind);
			end

		end %********************** END sortMatrices() ********************

		function show(obj, varargin)

			out = "";

			out = strcat("No. Variables: ", num2str(obj.numVar), string(newline));
			

			trim_len = 45;

			if numel(obj.varsFlat) > 0
				
				out = strcat(out, string(newline));
% 				out = strcat(out, string(newline), "Scalar Variables:", string(newline));

				i = 0;
				flatTable = MTable();
				flatTable.row(["Name", "Type", "Value", "Description"]);
				for v=obj.varsFlat
					i = i + 1;

					flatTable.row([string(v.name), string(v.type), v.getValueStr(), string(v.desc)]);
					% flatTable.row([limitLength(v.name, nameCap), limitLength(v.type, typeCap), limitLength(v.getValueStr(), valCap), limitLength(string(v.desc), descCap)]);

				end
				flatTable.title("Scalar Variables");
				flatTable.alignt('c');
				flatTable.alignah('l');
				flatTable.alignac('l');
				flatTable.trimac('c', trim_len);
				out = strcat(out, flatTable.str());
			end

	
			if numel(obj.vars1D) > 0
				out = strcat(out, string(newline));
% 				out = strcat(out, string(newline), "1D Variables:", string(newline));
				i = 0;
				matTable1 = MTable();
				matTable1.row(["Name", "Type", "Value", "Description"]);
				for v=obj.vars1D
					i = i + 1;

					matTable1.row([string(v.name), string(v.type), v.getValueStr(), string(v.desc)]);
					% flatTable.row([limitLength(v.name, nameCap), limitLength(v.type, typeCap), limitLength(v.getValueStr(), valCap), limitLength(string(v.desc), descCap)]);

				end
				matTable1.title("1D Vector Variables");
				matTable1.alignt('c');
				matTable1.alignah('l');
				matTable1.alignac('l');
				matTable1.trimac('c', trim_len);
				out = strcat(out, matTable1.str());
			end

			if numel(obj.vars2D) > 0
				out = strcat(out, string(newline));
% 				out = strcat(out, string(newline), "2D Variables:", string(newline));
				i = 0;
				matTable2 = MTable();
				matTable2.row(["Name", "Type", "Value", "Description"]);
				for v=obj.vars2D
					i = i + 1;

					matTable2.row([string(v.name), string(v.type), v.getValueStr(), string(v.desc)]);
					% flatTable.row([limitLength(v.name, nameCap), limitLength(v.type, typeCap), limitLength(v.getValueStr(), valCap), limitLength(string(v.desc), descCap)]);

				end
				matTable2.title("2D Vector Variables");
				matTable2.alignt('c');
				matTable2.alignah('l');
				matTable2.alignac('l');
				matTable2.trimac('c', trim_len);
				out = strcat(out, matTable2.str());
			end
			
			disp(out);

		end

		function showMTable(obj)

			disp(strcat("No. Variables: ", num2str(obj.numVar)));
			nameCap = 10;
			typeCap = 10;
			valCap = 20;
			descCap = 20;

			names = strings([length(obj.varsFlat), 1]);
			types = strings([length(obj.varsFlat), 1]);
			vals = strings([length(obj.varsFlat), 1]);
			descs = strings([length(obj.varsFlat), 1]);

			i = 0;
			for v=obj.varsFlat
				i = i + 1;
				names(i) = limitLength(v.name, nameCap);
				types(i) = limitLength(v.type, typeCap);
				vals(i) = limitLength(v.getValueStr(), valCap);
				descs(i) = limitLength(string(v.desc), descCap);
			end
			TF = table(names, types, vals, descs);

			disp("-----------------------------------------------------------------------");
			disp("| Flat Variables                                                      |");
			disp("-----------------------------------------------------------------------");
			disp(TF);
			disp(" ");
			disp(" ")

			names = strings([length(obj.vars1D), 1]);
			types = strings([length(obj.vars1D), 1]);
			vals = strings([length(obj.vars1D), 1]);
			descs = strings([length(obj.vars1D), 1]);

			i = 0;
			for v=obj.vars1D
				i = i + 1;
				names(i) = limitLength(v.name, nameCap);
				types(i) = limitLength(v.type, typeCap);
				vals(i) = limitLength(v.getValueStr(), valCap);
				descs(i) = limitLength(string(v.desc), descCap);
			end
			T1D = table(names, types, vals, descs);
			disp("-----------------------------------------------------------------------");
			disp("| 1D Variables                                                        |");
			disp("-----------------------------------------------------------------------");
			disp(T1D);
			disp(" ");
			disp(" ")

			names = strings([length(obj.vars2D), 1]);
			types = strings([length(obj.vars2D), 1]);
			vals = strings([length(obj.vars2D), 1]);
			descs = strings([length(obj.vars2D), 1]);

			i = 0;
			for v=obj.vars2D
				i = i + 1;
				names(i) = limitLength(v.name, nameCap);
				types(i) = limitLength(v.type, typeCap);
				vals(i) = limitLength(v.getValueStr(), valCap);
				descs(i) = limitLength(string(v.desc), descCap);
			end
			T2D = table(names, types, vals, descs);
			disp("-----------------------------------------------------------------------");
			disp("| 2D Variables                                                        |");
			disp("-----------------------------------------------------------------------");
			disp(T2D);

		end

		function showOldTable(obj) %*************** show() ************************

			disp(strcat("No. Variables: ", num2str(obj.numVar)));
			nameCap = 10;
			typeCap = 10;
			valCap = 20;
			descCap = 20;

			names = strings([length(obj.varsFlat), 1]);
			types = strings([length(obj.varsFlat), 1]);
			vals = strings([length(obj.varsFlat), 1]);
			descs = strings([length(obj.varsFlat), 1]);

			i = 0;
			for v=obj.varsFlat
				i = i + 1;
				names(i) = limitLength(v.name, nameCap);
				types(i) = limitLength(v.type, typeCap);
				vals(i) = limitLength(v.getValueStr(), valCap);
				descs(i) = limitLength(string(v.desc), descCap);
			end
			TF = table(names, types, vals, descs);

			disp("-----------------------------------------------------------------------");
			disp("| Flat Variables                                                      |");
			disp("-----------------------------------------------------------------------");
			disp(TF);
			disp(" ");
			disp(" ")

			names = strings([length(obj.vars1D), 1]);
			types = strings([length(obj.vars1D), 1]);
			vals = strings([length(obj.vars1D), 1]);
			descs = strings([length(obj.vars1D), 1]);

			i = 0;
			for v=obj.vars1D
				i = i + 1;
				names(i) = limitLength(v.name, nameCap);
				types(i) = limitLength(v.type, typeCap);
				vals(i) = limitLength(v.getValueStr(), valCap);
				descs(i) = limitLength(string(v.desc), descCap);
			end
			T1D = table(names, types, vals, descs);
			disp("-----------------------------------------------------------------------");
			disp("| 1D Variables                                                        |");
			disp("-----------------------------------------------------------------------");
			disp(T1D);
			disp(" ");
			disp(" ")

			names = strings([length(obj.vars2D), 1]);
			types = strings([length(obj.vars2D), 1]);
			vals = strings([length(obj.vars2D), 1]);
			descs = strings([length(obj.vars2D), 1]);

			i = 0;
			for v=obj.vars2D
				i = i + 1;
				names(i) = limitLength(v.name, nameCap);
				types(i) = limitLength(v.type, typeCap);
				vals(i) = limitLength(v.getValueStr(), valCap);
				descs(i) = limitLength(string(v.desc), descCap);
			end
			T2D = table(names, types, vals, descs);
			disp("-----------------------------------------------------------------------");
			disp("| 2D Variables                                                        |");
			disp("-----------------------------------------------------------------------");
			disp(T2D);

		end %*************************** END show() ***********************

		function write(obj, filename, options) %********* write() *********

			if ~exist('options','var')
				options = "";
			end

			kstr = obj.swrite(options);

			[fid, message] = fopen(filename,'w+');
			
			if fid == -1
				warning("Failed to open file '" + filename + "' (" + message + ")");
				return;
			end
			
			fprintf(fid, kstr);
			fclose(fid);

		end %******************************* END write() ******************

		% Writes the currently loaded variables to a DDF file on disk.
		%
		% Options: (Order does not matter. Case-sensitive)
		% 	v: Save all matrices as vertical
		%	o: Optimize size by removing lines intended to improve human-readability.
		%	d: Decapitate - ie. omit header
		%	-: Do not print version statement. WARNING: This will make the file unreadable.
		%		Don't use it unless you know what you're doing.
		%	s: Sort vectors largest to smallest
		%	u: Undocumented - variable descriptions are not printed
		%
		% In the event of an error, it returns a blank string
		function fstr=swrite(obj, options) %******* swrite() **************

			if ~exist('options','var')
				options = "";
			end

			nl = string(newline);

			options = string(options);

			%Initialize options
			vertical_mode = false;
			optimize = false;
			decapitate = false;
			skip_version = false;
			sort_mats = false;
			show_descriptions = true;

			%Read options
			if ~isempty(find(char(options)=='v',1))
				vertical_mode = true;
			end
			if ~isempty(find(char(options)=='o',1))
				optimize = true;
			end
			if ~isempty(find(char(options)=='d',1))
				decapitate = true;
			end
			if ~isempty(find(char(options)=='-',1))
				skip_version = true;
			end
			if ~isempty(find(char(options)=='s',1))
				sort_mats = true;
			end
			if ~isempty(find(char(options)=='u',1))
				show_descriptions = false;
			end

			%Write version statement
			out = strcat("#VERSION ", obj.current_version_str, nl);
			if ~optimize
				out = strcat(out, nl);
			end
			
			if skip_version
				out = "";
			end

			%Write header statement
			if ~decapitate && obj.header ~= ""
				out = strcat(out, "#HEADER", nl, obj.header, nl, "#HEADER", nl);
				if ~optimize
					out = strcat(out, nl);
				end
			end

			%Write flat variables
			for v=obj.varsFlat

				%Get string for value
				valstr = v.getValueStr();
				if valstr == "ERROR"
					obj.logErr("Invalid type in flat variable!");
					return;
				end

				%Create variable definition
				out = strcat(out, v.getTypeStr(), " ", v.name, " ", valstr);

				%Add description
				if v.desc ~= "" && show_descriptions
					out = strcat(out, " ?", v.desc);
				end

				%Carriage return
				out = strcat(out, nl);

			end

			%Sort matrices if required
			if sort_mats || vertical_mode
				obj.sortMatrices();
			end

			if ~vertical_mode %------------- Horizontal mode matrices -----

				%For each 1D matrix...
				for v = obj.vars1D

					%Get string for value
					valstr = v.getValueStr();
					if valstr == "ERROR"
						obj.logErr("Invalid type in flat variable!");
						return;
					end

					%Create variable definition
					out = strcat(out, v.getTypeStr(), " ", v.name, " ", valstr);

					%Add description
					if v.desc ~= "" && show_descriptions
						out = strcat(out, " ?", v.desc);
					end

					%Carriage return
					out = strcat(out, nl);

				end

				%For each 2D matrix...
				for v = obj.vars2D

					%Get string for value
					valstr = v.getValueStr();
					if valstr == "ERROR"
						obj.logErr("Invalid type in flat variable!");
						return;
					end

					%Create variable definition
					out = strcat(out, v.getTypeStr(), " ", v.name, " ", valstr);

					%Add description
					if v.desc ~= "" && show_descriptions
						out = strcat(out, " ?", v.desc);
					end

					%Carriage return
					out = strcat(out, nl);

				end



			else %------------------ END horiz, start vert. mode matrix ---
				
				% Print 1D matrices in their own vertical block
				out = strcat(out, nl, "#VERTICAL", nl);
				
				if ~optimize
					out = strcat(out, "//1D Vectors", nl);
				end
				
				% Get type declaration line
				typestr = "";
				for v = obj.vars1D
					if typestr ~= ""
						typestr = strcat(typestr, " ");
					end
					typestr = strcat(typestr, v.getTypeStr());
				end
				out = strcat(out, typestr, nl);
				
				% Get name declaration line
				typestr = "";
				for v = obj.vars1D
					if typestr ~= ""
						typestr = strcat(typestr, " ");
					end
					typestr = strcat(typestr, v.name());
				end
				out = strcat(out, typestr, nl);
				
				% Get description line
				found_desc = false;
				typestr = "";
				if show_descriptions
					for v = obj.vars1D
						if typestr ~= ""
							typestr = strcat(typestr, " ");
						end
						typestr = strcat(typestr, "?", v.desc());
						if v.desc ~= ""
							found_desc = true;
						end
					end
				end
				if found_desc
					out = strcat(out, typestr, nl);
				end
				
				% Print data
				elnum = 1;
				while true
					
					% Get data line
					typestr = "";
					for v = obj.vars1D
						if typestr ~= ""
							typestr = strcat(typestr, " ");
						end
						typestr = strcat(typestr, v.getValueStrIdx(elnum));
					end
					
					% Check for all variables out of data
					if typestr == ""
						break;
					end
					
					% Increment counter
					elnum = elnum+1;
					
					% Add to output
					out = strcat(out, typestr, nl);
				end
								
				out = strcat(out, "#VERTICAL", nl);
				
				% Print 2D matrices in their own vertical block
				out = strcat(out, nl, "#VERTICAL", nl);
				
				if ~optimize
					out = strcat(out, "//2D Vectors", nl);
				end
				
				% Get type declaration line
				typestr = "";
				for v = obj.vars2D
					if typestr ~= ""
						typestr = strcat(typestr, " ");
					end
					typestr = strcat(typestr, v.getTypeStr());
				end
				out = strcat(out, typestr, nl);
				
				% Get name declaration line
				typestr = "";
				for v = obj.vars2D
					if typestr ~= ""
						typestr = strcat(typestr, " ");
					end
					typestr = strcat(typestr, v.name());
				end
				out = strcat(out, typestr, nl);
				
				% Get description line
				found_desc = false;
				typestr = "";
				if show_descriptions
					for v = obj.vars2D
						if typestr ~= ""
							typestr = strcat(typestr, " ");
						end
						typestr = strcat(typestr, "?", v.desc());
						if v.desc ~= ""
							found_desc = true;
						end
					end
				end
				if found_desc
					out = strcat(out, typestr, nl);
				end
				
				% Print data
				elnum = 1;
				while true
					
					% Get data line
					typestr = "";
					for v = obj.vars2D
						if typestr ~= ""
							typestr = strcat(typestr, " ");
						end
						typestr = strcat(typestr, v.getValueStrIdx(elnum));
					end
					
					% Check for all variables out of data
					if typestr == ""
						break;
					end
					
					% Increment counter
					elnum = elnum+1;
					
					% Add to output
					out = strcat(out, typestr, nl);
				end
								
				out = strcat(out, "#VERTICAL", nl);
				
			end %--------------------- END matrix print

			fstr = out;
		end %*********************** END swrite() *************************

		function load(obj, filename) %********************* load() *********************

			obj.readVersion(filename);

			if obj.fileVersion == -1
				obj.logErr(strcat("Failed to load file '", filename ,"'. Unable to determine file version."))
				return;
			end

			if obj.fileVersion == 1
				obj.loadDDF_V1(filename)

			end

		end %**************************** END load() **********************

		function readVersion(obj, fileIn) %********************** readVersion() ******

			lnum = 0;
			foundHeader = 0;

            %Open file
            fid = fopen(fileIn);
			if fid == -1
				obj.logErr(strcat('Failed to open file "', fileIn, '"'));
				return;
			end

            %Read file line by line
            while(~feof(fid)) %- - - - - - - Loop Through File - - - - - -

                sline = fgetl(fid); %Read line
                lnum = lnum+1; %Increment Line Number

				%Remove comments
				sline = trimtok(sline, '//');

                %Note: char(9) is the tab character
				sline = ensureWhitespace(sline, ';');
                words = parseIdx(sline, [" ", char(9)]);

				%Skip blank lines
				if isempty(words)
					continue
				end

				% Check for each type of file elements
				if words(1).str == "#VERSION"

					%Ensure 2 words present
					if length(words) ~= 2
						obj.fileVersion = -1;
						obj.logErrLn('Version statement accepts exactly 2 words', lnum);
						return;
					end

					%Read version statement
					obj.fileVersion = str2double(words(2).str);
					if isnan(obj.fileVersion)
						obj.fileVersion = -1;
						obj.logErrLn(strcat("Failed to convert version number '",words(2).str , "' to string"), lnum);
					end

					break;
				end
			end

		end %************************************ END readVersion() *******

        function loadDDF_V1(obj, fileIn) %***** loadDDF_V1() *****

            lnum = 0;
			foundHeader = 0;

            %Open file
            fid = fopen(fileIn);
			if fid == -1
				obj.logErr(strcat('Failed to open file "', fileIn, '"'));
				return;
			end

            %Read file line by line
            while(~feof(fid)) %- - - - - - - Loop Through File - - - - - -

                sline = fgetl(fid); %Read line
                lnum = lnum+1; %Increment Line Number

				%Remove comments
				sline = trimtok(sline, '//');

                %Note: char(9) is the tab character
				sline = ensureWhitespace(sline, ';');
                words = parseIdx(sline, [" ", char(9)]);

				%Skip blank lines
				if isempty(words)
					continue
				end

				% Check for each type of file elements
				if words(1).str == "#VERSION"

					%Ensure 2 words present
					if length(words) ~= 2
						obj.logErrLn('Version statement accepts exactly 2 words', lnum);
						return;
					end

					%Read version statement
					obj.fileVersion = str2double(words(2).str);
					if isnan(obj.fileVersion)
						obj.fileVersion = -1;
						obj.logErrLn(strcat("Failed to convert version number '",words(2).str , "' to string"), lnum);
					end
				elseif words(1).str == "#HEADER"

					obj.header = "";
					openedOnLine = lnum;

					 while(~feof(fid))
						 sline = fgetl(fid); %Read line
						 sline = trimtok(sline, '//'); %Trim comments
						 lnum = lnum + 1;
						 words = parseIdx(sline, [" ", char(9)]);
						 if (~isempty(words)) && (words(1).str == "#HEADER")
							 foundHeader = 1;
							 break;
						 else
							 if obj.header ~= ""
								 obj.header = strcat(obj.header, string(newline), sline);
							 else
								 obj.header = sline;
							 end
						 end
					 end

					 if ~foundHeader
						 obj.logErrLn('Failed to find closing #HEADER statement', openedOnLine);
						 return;
					 end
				elseif words(1).str == "//" %TODO: Do I need to change this to check only the first two characters?

					%Is a comment
					continue;
				elseif words(1).str == "d" || words(1).str == "b" || words(1).str == "s" || words(1).str == "m<d>" || words(1).str == "m<s>" || words(1).str == "m<b>"

					%Check at least 3 words present
					if length(words) < 3
						obj.logErrLn('Insufficient number of tokens for inline variable statement', lnum);
						return;
					end

					%Check that name is valid
					if ~obj.isValidName(words(2).str)
						obj.logErrLn(strcat('Invalid variable name "', words(2).str, '"'), lnum);
						return;
					end

					%Read value
					if words(1).str == "d" || words(1).str == "b"
						if words(1).str == "d"
							newVal = str2double(words(3).str);
						elseif words(1).str == "b"
							newVal = str2logical(words(3).str);
						end
						temp = DDFItem(newVal, words(2).str, "");
						if isnan(temp.val)
							obj.logErrLn('Invlaid variable value', lnum);
							return;
						end

						%Scan through optional features
						indesc = false;
						for w=words(4:end)
							cstr = char(w.str);
							if w.str == "?" || cstr(1) == '?'
								indesc = true;
								temp.desc = strtrim(string(sline(w.idx+2:end))); %TODO: This will include inline comments. Go through document at beginning and purge all comments
							elseif w.str == "//"
								break; %Remainder is comment
							elseif ~indesc
								obj.logErrLn(strcat("Superfluous character after variable declaration ('", w.str , "')"), lnum);
								return;
							end
						end

						if isempty(obj.varsFlat)
							obj.varsFlat = temp;
						else
							obj.varsFlat(end+1) = temp;
						end
					elseif words(1).str == "s"

						%Create new DDFItem
						temp = DDFItem("", words(2).str, "");

						%Get string contents
						val = getString(sline);
						if isempty(val)
							obj.logErrLn("Failed to find string value", lnum);
							return;
						end
						valchar = char(val.str());
						temp.val = string(valchar(2:end-1));

						%Scan through optional features
						remainingwords = parseIdx(sline(val.idx+1:end), [" ", char(9)]);
						indesc = false;
						for w=remainingwords
							cstr = char(w.str);
							if w.str == "?" || cstr(1) == '?'
								indesc = true;
								temp.desc = strtrim(string(sline(val.idx+2+w.idx:end))); %TODO: This will include inline comments. Go through document at beginning and purge all comments
							elseif w.str == "//"
								break; %Remainder is comment
							elseif ~indesc
								obj.logErrLn(strcat("Superfluous character after variable declaration ('", w.str , "')"), lnum);
								return;
							end
						end

						if isempty(obj.varsFlat)
							obj.varsFlat = temp;
						else
							obj.varsFlat(end+1) = temp;
						end

					else %is m<X>

						%Create new DDFItem
						temp = DDFItem("", words(2).str, "");
						type = "";
						if ~isempty(find(char(words(1).str)=='d', 1))
							temp.type = "d";
						elseif ~isempty(find(char(words(1).str)=='s', 1))
							temp.type = "s";
						elseif ~isempty(find(char(words(1).str)=='b', 1))
							temp.type = "b";
						else
							obj.logErrLn(strcat("Failed to identiy matrix type ", words(1).str ), lnum);
							return;
						end


						%Get matrix contents
						[newmat, endIdx] = getMatrix(sline, temp.type); %TODO: Cannot handle strings in matrix with commas in the strings. Semicolons too.
						if endIdx == -1
							obj.logErrLn(strcat("Failed to read matrix value (", newmat , ")"), lnum);
							return;
						end
						temp.val = newmat;
						temp.updateCount();

						%Scan through optional features
						remainingwords = parseIdx(sline(endIdx+1:end), [" ", char(9)]);
						indesc = false;
						for w=remainingwords
							cstr = char(w.str);
							if w.str == "?" || cstr(1) == '?'
								indesc = true;
								temp.desc = strtrim(string(sline(endIdx+2+w.idx:end))); %TODO: This will include inline comments. Go through document at beginning and purge all comments
							elseif w.str == "//"
								break; %Remainder is comment
							elseif ~indesc
								obj.logErrLn(strcat("Superfluous character after variable declaration ('", w.str , "')"), lnum);
								return;
							end
						end

						if temp.dimension == 2
							if isempty(obj.vars1D)
								obj.vars1D = temp;
							else
								obj.vars1D(end+1) = temp;
							end
						else
							if isempty(obj.vars2D)
								obj.vars2D = temp;
							else
								obj.vars2D(end+1) = temp;
							end
						end


					end
				elseif words(1).str == "#VERTICAL"

					vertBlock = [];
					line_nums = [];
					openedOnLine = lnum;
					foundBlock = false;
					while(~feof(fid))
						sline = fgetl(fid); %Read line
						sline = trimtok(sline, '//'); %Trim comments
						lnum = lnum + 1;
						words = parseIdx(sline, [" ", char(9)]);

						%Skip blank lines
						if isempty(words)
							continue;
						end

						%Skip lines starting as comments
						cstr = words(1).str;
						if length(words(1).str) >= 2 &&  strcmp(cstr(1:2), '//')
							continue;
						end

						%Read line contents
						if (words(1).str == "#VERTICAL")
							foundBlock = true;
							break;
						else %is part of block

							%Remove inline comments
							cstr = char(sline);
							dashes = find(cstr=='/'); %Find dash characters
							dash_del = find(diff(dashes)==1, 1, 'first'); %Find consecutive dashes
							if ~isempty(dash_del) %comment present
								cstr = cstr(1:dashes(dash_del)-1);
								sline = string(cstr);
							end

							%Add to matrix of lines
							if isempty(vertBlock)
								vertBlock = string(sline);
								line_nums = lnum;
							else
								vertBlock(end+1) = string(sline);
								line_nums(end+1) = lnum;
							end
						end
					end

					%Ensure block terminus was found
					if ~foundBlock
						obj.logErrLn('Failed to find closing #VERTICAL statement', openedOnLine);
						return;
					end

					%Ensure block is sufficient size
					if length(vertBlock) < 3
						obj.logErrLn("Found fewer than three non-blank lines in vertical block.", openedOnLine);
						return;
					end

					%Get types
					types = parseIdx(vertBlock(1), [" ", char(9)]);

					%Get names
					names = parseIdx(vertBlock(2), [" ", char(9)]);

					%Check if descriptions present
					cstr = char(strtrim(vertBlock(3)));
					descs = [];
					if cstr(1) == '?'
						descs = parseIdx(vertBlock(3), "?");
					end

					%Check for errors in list sizes
					if (length(types) ~= length(names)) || (~isempty(descs) && length(descs) ~= length(names))
						obj.logErrLn(strcat("Number of type declarations (", num2str(length(types)) ,"), names (", num2str(length(names)) ,"), and descriptions (", num2str(length(descs)) ,"), if present, must match.") , openedOnLine);
						return;
					end

					%Check names are valid
					c=1;
					for n=names
						if ~obj.isValidName(n.str)
							obj.logErrLn(strcat("Name '", n.str, "' is invalid."), line_nums(c));
							return;
						end
						c=c+1;
					end

					%Check types are valid
					c=1;
					for t=types
						if t.str ~= "m<d>" && t.str ~= "m<s>" && t.str ~= "m<b>"
							obj.logErrLn(strcat("Type '", t.str, "' is invalid."), line_nums(c));
							return;
						end
						c=c+1;
					end

					%Initialize data_strs matrix
					data_strs = "";
					for i=2:length(names)
						data_strs(end+1) = "";
					end

					%Break lines into vectors
					maxAllowed = length(names);
					startRow = 3;
					if ~isempty(descs)
						startRow = 4;
					end
					c=startRow;
					for l=vertBlock(startRow:end)

						%Parse line without breaking up string
						assignin('base', 'problemString', l);
						assignin('base', 'problemLine', lnum);
						words = parseIdx(l, strcat(" ", string(char(9))), true);

						%Check that matrix didn't omit data one line, then
						%bring it back later
						if length(words) > maxAllowed
							obj.logErrLn("Too many columns detected.", line_nums(c));
							return;
						end

						%Update max No. allowed tokens
						if length(words) < maxAllowed
							maxAllowed = length(words);
						end

						%For each token, add to corresponding data string
						for wi=1:length(words)

							%Add comma if data string not blank and last
							%line was not semicolon
							cstr = strtrim(data_strs(wi));
							if data_strs(wi) ~= "" && cstr(end) ~= ';'
								data_strs(wi) = strcat(data_strs(wi), ",");
							end

							%Add new data
							data_strs(wi) = strcat(data_strs(wi), words(wi).str);
						end


						c=c+1;
					end

					for di=1:length(types)

						%Create new DDFItem
						temp = DDFItem("", names(di).str, "");
						typestr = char(types(di).str);
						typestr = string(typestr(3));
						temp.type = typestr;
						if ~isempty(descs)
							temp.desc = strtrim(descs(di).str);
						end

						%Get matrix contents
						data_strs(di) = strcat("[", data_strs(di), "]");
						[newmat, endIdx] = getMatrix(data_strs(di), typestr); %TODO: Cannot handle strings in matrix with commas in the strings. Semicolons too.
						if endIdx == -1
							obj.logErrLn(strcat("Failed to read matrix value (", data_strs(di) , ", type=", typestr , ") in vertical block"), openedOnLine);
							return;
						end
						temp.val = newmat;
						temp.updateCount();

						%Scan through optional features
						remainingwords = parseIdx(sline(endIdx+1:end), [" ", char(9)]);
						indesc = false;
						for w=remainingwords
							cstr = char(w.str);
							if w.str == "?" || cstr(1) == '?'
								indesc = true;
								temp.desc = sline(endIdx+1+w.idx:end); %TODO: This will include inline comments. Go through document at beginning and purge all comments
							elseif w.str == "//"
								break; %Remainder is comment
							elseif ~indesc
								obj.logErrLn(strcat("Superfluous character after variable declaration ('", w.str , "')"), lnum);
								return;
							end
						end

						if temp.dimension == 2
							if isempty(obj.vars1D)
								obj.vars1D = temp;
							else
								obj.vars1D(end+1) = temp;
							end
						else
							if isempty(obj.vars2D)
								obj.vars2D = temp;
							else
								obj.vars2D(end+1) = temp;
							end
						end

					end

				end %-------------------- END check match file element ----

            end %- - - - - - - - - - - - END Loop Through File - - - - - -
		end %************************ END loadDDF_V1() ********************








	end   %************************ END METHODS ***************************
end
