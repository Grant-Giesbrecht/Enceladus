classdef AWRLPmdf < handle
	
	properties
		
		% Global data taken from the header
		% This property is formatted as an array of AWRLPvar's.
		gdata 
		
	
		% Block data, this is the main data, ie the data contained in each
		% of the repeating blocks of the file. Because it repeats in an
		% extra dimension compared to 'gdata' above, it is not just an
		% array of AWRLPvars, but a cell array, each cell containing an
		% array of AWRLPvars similar to gdata.
		bdata
		
		% This is a list of AWRLPvars similar to gdata, except instead of
		% containing actual data it describes the format that should be
		% looked for when populating bdata above. It is created in the
		% header ABWAVE block
		bform
		bTokensPerLine
		bVarsPerLine
		varline

		% Grid describing 'validity' of data, by which format means length
		% of each variable in a block
		validityGrid
		
		% Message out
		msg
		debug
		
		filename
		
	end
	
	methods
		
		function obj = AWRLPmdf()
		
			obj.gdata = [];
			obj.bdata = {};
			
			obj.bform = [];
			obj.bTokensPerLine = [];
			obj.bVarsPerLine = [];
			obj.varline = [];
			
			obj.validityGrid = [];
			
			obj.msg = "";
			
			obj.debug = false;
			
			obj.filename = "";
		end
		
		function tf = load(obj, filename)
			
			obj.filename = filename;
			
			tf = true;
			
			%Open file
            fid = fopen(filename);
			if fid == -1
				obj.msg = strcat('Failed to open file "', filename, '"');
				return;
			end

			% Define file state/location
			% 0 - Pre-data (header, and vars okay)
			% 1 - in header block
			% 2 - in ABWAVES
			% 4 - In data blocks
			location = 0;
			recheck = false;
			blockIdx = 0;
			
            %Read file line by line
			lnum = 0;
			while(~feof(fid))
				
				if ~recheck % Get next line
					sline = fgetl(fid); %Read line
					lnum = lnum+1; %Increment Line Number

					%Remove comments
					sline = trimtok(sline, '!');

					%Note: char(9) is the tab character
					words = parseIdx(sline, [" ", char(9)]);

					%Skip blank lines, but reset blockIdx counter to zero
					if isempty(words)
						blockIdx = 0;
						continue
					end
				else % Recheck prior line (will be processed new way)
					recheck = false;
				end
				
				if obj.debug 
					displ("<L", lnum , "> ", sline, " [Mode: ", location , "]");
				end
				
				% Change search behavior based on file state/location
				switch location
					
					case 0 % Pre-data (header, vars okay)
						
						% Check for each type of file elements
						if (words(1).str == "BEGIN" || words(1).str == "BEGIN<>") && length(words) >= 2 && words(2).str == "HEADER"
							location = 1;
						elseif (words(1).str == "BEGIN" || words(1).str == "BEGIN<>") && length(words) >= 2 && words(2).str == "ABWAVES"
							location = 2;
						elseif words(1).str == "VAR" || words(1).str == "VAR<>"
							
							% Check for unsupported formats (ie. var has
							% '=' on same line)
							if length(words) ~= 2
								error(strcat("Wrong number of tokens on line", num2str(lnum), ". Likely an unsupported VAR/VAR<> format, such as including an '='."));
							end
							
							
							% Add formatting data to bdata
							nv = AWRLPvar(words(2).str);
							nv.declareLine = lnum;
							obj.bform = addTo(obj.bform, nv);
						else % Unrecognized, must be data block
							
							location = 3; % Change to data block mode
							recheck = true; % Reprocess line
							
							% Here you can run any processes that need to
							% occur after the header is complete and the
							% data scan process is about to start
							
							% Determine the shape of the data blocks from
							% obj.bform data
							if ~obj.calcTokensPerLine()
								tf = false;
								return;
							end
							
						end
						
					case 1 % in header block
						if words(1).str == "%" % Column titles
							
							% Loop through words and create global
							% variables
							obj.gdata = [];
							for w = words(2:end)
								obj.gdata = addTo(obj.gdata, AWRLPvar(w.str));
							end
							
						elseif words(1).str == "END" %End block
							location = 0; % Set mode back to general
						else % Must be data
							
							obj.gdata = AWRLPmdf.matchData2Vars(words, obj.gdata);
							
						end
					case 2 % InABWAVES block
						if words(1).str == "%" % Column titles
							
							% Loop through words and create block
							% variables
							for w = words(2:end)
								nv = AWRLPvar(w.str);
								nv.declareLine = lnum;
								obj.bform = addTo(obj.bform, nv);
							end
							
						elseif words(1).str == "END" || words(1).str == "END<>" %End block
							location = 0; % Set mode back to general
							
% 							% Use the validity grid to compute the lengths
% 							if ~obj.runValidityGrid()
% 								tf = false;
% 								return;
% 							end
							
						else % Must be availability/length data
							
							% Create new grid row
							newGridRow = [];
							for w = words
								newGridRow = addTo(newGridRow, string(w.str));
							end
							
							% Add to total grid
							obj.validityGrid = [obj.validityGrid; newGridRow];
							
						end
					case 3 % In data blocks
						
						% Block index refers to the line in the data block,
						% NOT the index of the variable being assigned
						blockIdx = blockIdx + 1;
						
						% Check that correct number of tokens/values are
						% on this line of the file
						if length(words) ~= obj.bTokensPerLine(blockIdx)
							tf = false;
							obj.msg = "Data block on line" + num2str(lnum) + "is the wrong size!";
							return;
						end
						
						% If entering new block, copy bform into new data array
						if blockIdx == 1

							data = [];
							for bd = obj.bform
								
								nv = AWRLPvar(bd.name);
								nv.data = bd.data;
								nv.size = bd.size;
								nv.declareLine = bd.declareLine;
								
								data = addTo(data, nv);
							end
							
							obj.bdata{end+1} = data;
						end
						
						% Assign data in words to obj.bdata{end} array
						wi = 1;
						
						% Get variables on line currently being read
						vll = obj.varline{blockIdx};
						
						% Scan through variables in varline
						for vi = 1:length(vll)
							
							if vll(vi).len == 1
								
								% Check length of words
								if wi > length(words)
									obj.msg = "Too few words on line " + num2str(lnum);
									tf = false;
									return;
								end
								
								% Get index of variable
								idx = obj.bdataIndex(vll(vi).name);
								if idx == -1
									obj.msg = "Failed to find variable";
									tf = false;
									return;
								end
								
								% Assign data
								data_arr = obj.bdata{end};
								data_arr(idx).assign(words(wi).str);
								obj.bdata{end} = data_arr;
								
								wi = wi + 1;
							else
								
								% Check length of words
								if wi+1 > length(words)
									obj.msg = "Too few words on line " + num2str(lnum);
									tf = false;
									return;
								end
								
								% Get index of variable
								idx = obj.bdataIndex(vll(vi).name);
								if idx == -1
									obj.msg = "Failed to find variable";
									tf = false;
									return;
								end
								
								% Assign data
								data_arr = obj.bdata{end};
								data_arr(idx).assign(words(wi).str, words(wi+1).str);
								obj.bdata{end} = data_arr;
								
								wi = wi + 2;
							end
							
						end
						
						% Is last line, reset block index
						if blockIdx == length(obj.varline)
							blockIdx = 0;
						end
						
					otherwise
						error("location variable in invalid state!");
				end
				
				
			end
			
		end
		
		function idx = bdataIndex(obj, name)
			
			if isempty(obj.bdata)
				error("Object empty, cannot find bdata index.");
			end
			
			idx = -1;
			
			arr = obj.bdata{end};
			
			
			for vi = 1:length(arr)
				
				if strcmp(arr(vi).name, name)
					idx = vi;
					return;
				end
				
			end
			
		end
		
% 		function tf = runValidityGrid(obj) %====== runValidityGrid() ======
% 			
% 			tf = true;
% 			
% 			% Check grid is correct size
% 			[r,c] = size(obj.validityGrid);
% 			if c ~= numel(obj.bform)
% 				msg = "Validity grid is wrong size.";
% 				tf = false;
% 				return;
% 			end
% 			
% 			%TODO: Will currently ignore this grid. Could later use to
% 			%check file is not broken/mis-interpreted
% 			
% 			% purpose is to populate 'validLen' param in AWRLPvar
% 			
% 		end %================== END runValidityGrid =======================
		
		function tf = calcTokensPerLine(obj) %====== calcTokensPerLine =========
		% CALCTOKENSPERLINE Determine shape of data block
		%
		% Using the data in obj.bform, determine the number of tokens per
		% line in a data block. This information is unsed in processing the
		% data blocks to come.
			
			tf = true;
		
			bIdx_abwave = -1;
		
			%************ Calculate Variables Per Line,  accounting for
			% repeated lines due to ABWAVE block **************************
		
			line = -1;
			bIdx = 1;
			count = 0;
			countWords = 0;
			
			% Scan through block format specifier
			for i=obj.bform
				
				% Check if new line
				if i.declareLine ~= line
					
					% Check that previous line was not blank, save it if
					% populated.
					if line ~= -1
						
						% Save location of AB wave block
						if countWords > 1 && bIdx_abwave == -1
							bIdx_abwave = bIdx;
						end
						
						% Save token count
% 						obj.bTokensPerLine(bIdx) = count;
						obj.bVarsPerLine(bIdx) = countWords;
						
						% Increment bIdx
						bIdx = bIdx + 1;
					end
					
					% Update line number
					line = i.declareLine;
					
					% Reset count
					count = 0;
					countWords = 0;
					
				end
				
				count = count + i.size;
				countWords = countWords + 1;
				
			end
			
			
			% Save last line
			%
			% Check that previous line was not blank, save it if
			% populated.
			if line ~= -1
				
				% Save location of AB wave block
				if countWords > 1 && bIdx_abwave == -1
					bIdx_abwave = bIdx;
				end

				% Save token count
% 				obj.bTokensPerLine(bIdx) = count;
				obj.bVarsPerLine(bIdx) = countWords;

				% Increment bIdx
				bIdx = bIdx + 1;
			end
			
			%************* Insert lines to bTokensPerLine, per the data in
			%validitygrid *************************************************
			
			% Check grid is a plausible size
			[r,c] = size(obj.validityGrid);
			if c < 1 || c > numel(obj.bform) || r < 1
				obj.msg = "Validity grid is wrong size.";
				tf = false;
				return;
			end
			
			% Calculate length of each row in validity grid
			vglen = [];
			for ridx=1:r
				vglen(ridx) = sum(obj.validityGrid(ridx,:) == "V");
			end
			
			% Check that max length of grid is length of AB wave param list
			if obj.bVarsPerLine(bIdx_abwave) ~= max(vglen);
				obj.msg = "Validity grid is not same size as AB Wave block.";
				tf = false;
				return;
			end
			
			% Update bTokensPerLine by expanding the ABWAVE line to the
			% correct number of rows, ea. of the correct length, according
			% to the validity grid's data.
			bIdx_endabwave = bIdx_abwave + length(vglen);
			obj.bVarsPerLine = [obj.bVarsPerLine(1:bIdx_abwave-1), vglen, obj.bVarsPerLine(bIdx_abwave+1:end)];
			
			
			%********* Populate VARLINE based on validity grid ************
			
			ptr_reset = -1;
			ptr = 1; % pointer to bform
			obj.varline = cell(1,length(obj.bVarsPerLine));
			
			vgrow = 0;
			
			% Loop over each line
			for ridx = 1:length(obj.bVarsPerLine)
				
				% Check if in ABWAVE block
				if ridx >= bIdx_abwave && ridx < bIdx_endabwave % Is in ABWAVE block
					
					% Look at next line of validity grid
					vgrow = vgrow + 1;
					
					% Save index of bform where ABWAVE block starts
					if ptr_reset == -1
						ptr_reset = ptr;
					else % Else if has already been saved, reset pointer to start
						ptr = ptr_reset;
					end
					
					% Loop over vars on line
					vidx = 1;
					while vidx <= obj.bVarsPerLine(ridx)
						
						% Skip 'missing' terms
						while strcmp(char(obj.validityGrid(vgrow, ptr-ptr_reset+1)), 'M')
							ptr = ptr + 1;
						end
						
						% Take next word and extract data
						if obj.bform(ptr).size == 1
							
							% Add variable to varline
							ns = struct('name', obj.bform(ptr).name, 'len', 1);
							obj.varline{ridx} = addTo(obj.varline{ridx}, ns);
							
							vidx = vidx + 1;
							
						else
							
							% Add variable to varline
							ns = struct('name', obj.bform(ptr).name, 'len', 2);
							obj.varline{ridx} = addTo(obj.varline{ridx}, ns);
							
							vidx = vidx + 1;
							
						end
						ptr = ptr + 1;
						
					end
					
				else %Not in ABWAVE block
					
					% Loop over words on line. 
					vidx = 1;
					while vidx <= obj.bVarsPerLine(ridx)
						
						% Take next word and extract data
						if obj.bform(ptr).size == 1
							
							% Add variable to varline
							ns = struct('name', obj.bform(ptr).name, 'len', 1);
							obj.varline{ridx} = addTo(obj.varline{ridx}, ns);
							
							vidx = vidx + 1;
							
						else
							
							% Add variable to varline
							ns = struct('name', obj.bform(ptr).name, 'len', 2);
							obj.varline{ridx} = addTo(obj.varline{ridx}, ns);
							
							vidx = vidx + 1;
							
						end
						ptr = ptr + 1;
						
					end
					
				end
				
			end
			
			%******** Calculate Tokens per line ***************************
			
			obj.bTokensPerLine = [];
			for vi = 1:numel(obj.varline)
				
				arr = obj.varline{vi};
				
				sumval = 0;
				for v=arr
					sumval = sumval + v.len;
				end
				
				obj.bTokensPerLine = addTo(obj.bTokensPerLine, sumval); 
				
			end
			
		end %===================== END calcTokensPerLine() ================
		
		function s = str(obj) %============== str() =======================
			
			gt = MTable;
			names = [];
			
			% Determine number of rows for table
			numrows = 0;
			for v = obj.gdata
				[r,~] = size(v.data);
				if r > numrows
					numrows = r;
				end
			end
			
			% Create data array
			rows = zeros(numrows, numel(obj.gdata));
			
			% Gather table data
			idx = 1;
			for v = obj.gdata
				
				% Collect names
				names = addTo(names, strcat(v.name, " SZ=", num2str(v.size)));
				
				% Collect data
				rows(:, idx) = v.getDataCol(numrows);
				
				idx = idx + 1;
			end
			
			% Populate table
			gt.title("Global Data");
			gt.row(names);
			for r = 1:numrows
				gt.row(string(rows(r, :)));
			end
			
			s = gt.str();
			
			% Print varline if in debug mode
			if obj.debug
				
				vt = MTable;
				
				vls = [];
				for i=1:numel(obj.varline)
					vls = addTo(vls, length(obj.varline{i}));
				end
				
				vt.title("VARLINE")
				
				% Create column titles
				titlestrs = [];
				for i=1:max(vls)
					titlestrs = addTo(titlestrs, strcat("Col ", num2str(i)));
				end
				
				vt.row(titlestrs);
				
				% Add each row
				for vi=1:numel(obj.varline)
					
					arr = obj.varline{vi};
					
					data = [];
					for i=1:length(arr)
						data = addTo(data, strcat(arr(i).name, " SZ=", num2str(arr(i).len), ""));
					end
					
					vt.row(data);
				end
				
				displ(vt.str());
				
			end
			
			if obj.debug
				btpl = MTable;
				btpl.title("bTokensPerLine");
				btpl.row(["Row", "No. Tokens"]);
				
				for i=1:numel(obj.bTokensPerLine)
					btpl.row([string(num2str(i)), string(num2str(obj.bTokensPerLine(i)))]);
				end
				
				displ(newline, btpl.str());
			end
			
		end %========================== END str() =========================
		
		function showBlock(obj, bn)
			
			%TODO: Show empty cells as something other than zero!
			bd = obj.bdata{bn};
			
			% Create table
			bt = MTable;
			bt.title("Block " + num2str(bn) + " Data");
			
			% Get max len
			dls = [];
			for b = bd
				[r,~] = size(b.data);
				dls = addTo(dls, r);
			end
			maxlen = max(dls);
			
			% Add row titles
			rowtitles = [];
			datacols = {};
			for b = bd
				rowtitles = addTo(rowtitles, b.name);
				
				datacols{end+1} = b.getDataCol(maxlen, NaN);
			end
			bt.row(rowtitles);
			
			
			
			% Add data
			for r=1:maxlen
				
				nr = [];
				for i=1:length(datacols)
					nr = addTo(nr, string(num2fstr(datacols{i}(r), 'nanstr', '--')));
				end
				
				bt.row(nr);
			end
			
			displ(bt.str());
		end
		
		function lps = getLPSweep(obj, removeHarmonics)
			
			if ~exist('removeHarmonics', 'var')
				removeHarmonics = true;
			end
			
			lps = LPSweep;
			
			for idx = 1:length(obj.bdata)
								
				lpp = LPPoint;
				
				% Get indeces of a and b waves in the data block
				a1idx = obj.bdataIndex("a1(3)");
				b1idx = obj.bdataIndex("b1(3)");
				a2idx = obj.bdataIndex("a2(3)");
				b2idx = obj.bdataIndex("b2(3)");

				% Save data from data block for indexing
				a1var = obj.bdata{idx}(a1idx);
				b1var = obj.bdata{idx}(b1idx);
				a2var = obj.bdata{idx}(a2idx);
				b2var = obj.bdata{idx}(b2idx);

				% Construct complex values from real + imag, add to output arrays
				if ~removeHarmonics
					lpp.a1 = addTo(lpp.a1, flatten(a1var.data(:, 1) + a1var.data(:, 2)*sqrt(-1)));	
					lpp.b1 = addTo(lpp.b1, flatten(b1var.data(:, 1) + b1var.data(:, 2)*sqrt(-1)));
					lpp.a2 = addTo(lpp.a2, flatten(a2var.data(:, 1) + a2var.data(:, 2)*sqrt(-1)));
					lpp.b2 = addTo(lpp.b2, flatten(b2var.data(:, 1) + b2var.data(:, 2)*sqrt(-1)));
				else
					lpp.a1 = addTo(lpp.a1, a1var.data(1, 1) + a1var.data(1, 2)*sqrt(-1));				
					lpp.b1 = addTo(lpp.b1, b1var.data(1, 1) + b1var.data(1, 2)*sqrt(-1));
					lpp.a2 = addTo(lpp.a2, a2var.data(1, 1) + a2var.data(1, 2)*sqrt(-1));
					lpp.b2 = addTo(lpp.b2, b2var.data(1, 1) + b2var.data(1, 2)*sqrt(-1));
				end
				
				% Populate 'props' from bdata cell
				for bi = 1:numel(obj.bdata{idx})
					
					% If index recognized as a1, a2, b1, b2, skip it
					if any(bi == [a1idx, a2idx, b1idx, b2idx])
						continue
					end
					
					lpvar = obj.bdata{idx}(bi);
					
					% Continue until harmonic number is reported (this will
					% indicate main data block instead of parameters)
					if contains(lpvar.name, "harm")
						continue;
					end
					
					% Else save to 'props'
					lpp.props.(AWRLPmdf.fieldName(lpvar.name)) = lpvar.data;
					
				end
				
				% Populate 'props' from global data
				for g = obj.gdata
					
					% Skip known to be unhelpful parameters
					if contains(g.name, "NHARM") || contains(g.name, "index")
						continue;
					end
					
					lpp.props.(AWRLPmdf.fieldName(g.name)) = g.data;
					
				end
				
				% Rename known properties
				lpp.formatData();
				
				% Add LPPoint to LPSweep.data
				lps.data = addTo(lps.data, lpp);
				
			end
						
		end
		
		function lps = getLPSweepOptimized(obj, removeHarmonics)
			
			if ~exist('removeHarmonics', 'var')
				removeHarmonics = true;
			end
			
			lps = LPSweep;
			data_idx = 1;
			lps.data = [];
			
			for idx = 1:length(obj.bdata)
								
				lpp = LPPoint;
				
				% Get indeces of a and b waves in the data block
				a1idx = obj.bdataIndex("a1(3)");
				b1idx = obj.bdataIndex("b1(3)");
				a2idx = obj.bdataIndex("a2(3)");
				b2idx = obj.bdataIndex("b2(3)");

				% Save data from data block for indexing
				a1var = obj.bdata{idx}(a1idx);
				b1var = obj.bdata{idx}(b1idx);
				a2var = obj.bdata{idx}(a2idx);
				b2var = obj.bdata{idx}(b2idx);

				% Construct complex values from real + imag, add to output arrays
				if ~removeHarmonics
					lpp.a1 = addTo(lpp.a1, flatten(a1var.data(:, 1) + a1var.data(:, 2)*sqrt(-1)));	
					lpp.b1 = addTo(lpp.b1, flatten(b1var.data(:, 1) + b1var.data(:, 2)*sqrt(-1)));
					lpp.a2 = addTo(lpp.a2, flatten(a2var.data(:, 1) + a2var.data(:, 2)*sqrt(-1)));
					lpp.b2 = addTo(lpp.b2, flatten(b2var.data(:, 1) + b2var.data(:, 2)*sqrt(-1)));
				else
					lpp.a1 = addTo(lpp.a1, a1var.data(1, 1) + a1var.data(1, 2)*sqrt(-1));				
					lpp.b1 = addTo(lpp.b1, b1var.data(1, 1) + b1var.data(1, 2)*sqrt(-1));
					lpp.a2 = addTo(lpp.a2, a2var.data(1, 1) + a2var.data(1, 2)*sqrt(-1));
					lpp.b2 = addTo(lpp.b2, b2var.data(1, 1) + b2var.data(1, 2)*sqrt(-1));
				end
				
				% Populate 'props' from bdata cell
				for bi = 1:numel(obj.bdata{idx})
					
					% If index recognized as a1, a2, b1, b2, skip it
					if any(bi == [a1idx, a2idx, b1idx, b2idx])
						continue
					end
					
					lpvar = obj.bdata{idx}(bi);
					
					% Continue until harmonic number is reported (this will
					% indicate main data block instead of parameters)
					if contains(lpvar.name, "harm")
						continue;
					end
					
					% Else save to 'props'
					lpp.props.(AWRLPmdf.fieldName(lpvar.name)) = lpvar.data;
					
				end
				
				% Populate 'props' from global data
				for g = obj.gdata
					
					% Skip known to be unhelpful parameters
					if contains(g.name, "NHARM") || contains(g.name, "index")
						continue;
					end
					
					lpp.props.(AWRLPmdf.fieldName(g.name)) = g.data;
					
				end
				
				% Rename known properties
				lpp.formatData();
				
				% Add LPPoint to LPSweep.data
				lps.data(data_idx) = lpp;
				data_idx = data_idx+1;
			end
						
		end
		
		function lpd = getLPData(obj)
			 
			warning("This function, getLPData(), is deprecated. 'getLPSweep()' should be used instead.");
			
			lpd = LPData;

			% Scan over each block
			for idx = 1:length(obj.bdata)

				% Get indeces of a and b waves in the data block
				a1idx = obj.bdataIndex("a1(3)");
				b1idx = obj.bdataIndex("b1(3)");
				a2idx = obj.bdataIndex("a2(3)");
				b2idx = obj.bdataIndex("b2(3)");

				% Save data from data block for indexing
				a1var = obj.bdata{idx}(a2idx);
				b1var = obj.bdata{idx}(b2idx);
				a2var = obj.bdata{idx}(a2idx);
				b2var = obj.bdata{idx}(b2idx);

				% Construct complex values from real + imag, add to output
				% arrays (only taking fundamental)
				lpd.a1 = addTo(lpd.a1, a1var.data(1, 1) + a1var.data(1, 2)*sqrt(-1));
				lpd.b1 = addTo(lpd.b1, b1var.data(1, 1) + b1var.data(1, 2)*sqrt(-1));
				lpd.a2 = addTo(lpd.a2, a2var.data(1, 1) + a2var.data(1, 2)*sqrt(-1));
				lpd.b2 = addTo(lpd.b2, b2var.data(1, 1) + b2var.data(1, 2)*sqrt(-1));

			end
		end
		
		function lp = getLoadPull(obj, removeHarmonics)
			
			% Verify that data is populated
			if isempty(obj.bdata)
				lp = LoadPull;
				warning("ARWLPmdf Object Empty: Returned empty load pull.");
				return;
			end
			
			% Handle optional arguments
			if ~exist('removeHarmonics', 'var')
				removeHarmonics = true;
			end
			
			% Initialize LoadPull object
			lp = LoadPull;
			
			% Get indeces of a and b waves in the data block
			a1idx = obj.bdataIndex("a1(3)");
			b1idx = obj.bdataIndex("b1(3)");
			a2idx = obj.bdataIndex("a2(3)");
			b2idx = obj.bdataIndex("b2(3)");

			V1idx = obj.bdataIndex("V1(1)");
			I1idx = obj.bdataIndex("I1(1)");
			V2idx = obj.bdataIndex("V2(1)");
			I2idx = obj.bdataIndex("I2(1)");
			
			% Determine length of object to create
			moduloHarm = length(obj.bdata);
			[nharm, ~] = size(obj.bdata{1}(a1idx).data); %Get number of harmonics
			if ~removeHarmonics
				len = moduloHarm*nharm;
			else
				len = moduloHarm;
			end
			
			% If only 1 frequency present, automatically ignore harmonics
			if nharm == 1
				removeHarmonics = true;
			end
			
			% Get harmonic numbers (if applicable)
			if ~removeHarmonics
				hi = obj.bdataIndex("harm(1)");
				harmNo = flatten(obj.bdata{1}(hi).data);
			end
			
			% Initialize variables to save time
			lp.a1 = zeros(1, len);
			lp.b1 = zeros(1, len);
			lp.a2 = zeros(1, len);
			lp.b2 = zeros(1, len);
			
			lp.V1_DC = zeros(1, len);
			lp.I1_DC = zeros(1, len);
			lp.V2_DC = zeros(1, len);
			lp.I2_DC = zeros(1, len);
			
			% Pre-allocate variables from bdata
			freq_in_bdata = false;
			for bi = 1:numel(obj.bdata{1})
				% If index recognized as a1, a2, b1, b2, skip it
				if any(bi == [a1idx, a2idx, b1idx, b2idx, V1idx, I1idx, V2idx, I2idx])
					continue;
				end

				lpvar = obj.bdata{1}(bi);

				% Continue until harmonic number is reported (this will
				% indicate main data block instead of parameters)
				if contains(lpvar.name, "harm")
					continue;
				end

				% Capture frequency in dedicated vector rather than
				% 'props'
				if contains(lpvar.name, "F1") || contains(lpvar.name, "F1(1)") || contains(upper(lpvar.name), "FREQ")
					lp.freq = zeros(1, len);
				end

				% Else save to 'props'
				lp.props.(AWRLPmdf.fieldName(lpvar.name)) = zeros(1, len);

			end
			
			% For each item in block-data
			for idx = 1:length(obj.bdata)
												
% 				% Get indeces of a and b waves in the data block
% 				a1idx = obj.bdataIndex("a1(3)");
% 				b1idx = obj.bdataIndex("b1(3)");
% 				a2idx = obj.bdataIndex("a2(3)");
% 				b2idx = obj.bdataIndex("b2(3)");
% 				
% 				V1idx = obj.bdataIndex("V1(1)");
% 				I1idx = obj.bdataIndex("I1(1)");
% 				V2idx = obj.bdataIndex("V2(1)");
% 				I2idx = obj.bdataIndex("I2(1)");

				% Save data from data block for indexing
				a1var = obj.bdata{idx}(a1idx);
				b1var = obj.bdata{idx}(b1idx);
				a2var = obj.bdata{idx}(a2idx);
				b2var = obj.bdata{idx}(b2idx);
				
				V1var = obj.bdata{idx}(V1idx);
				I1var = obj.bdata{idx}(I1idx);
				V2var = obj.bdata{idx}(V2idx);
				I2var = obj.bdata{idx}(I2idx);

				% Construct complex values from real + imag, add to output arrays
				if ~removeHarmonics
					
					% Add harmonics for 
					for nh = 1:nharm
						lp.a1(idx+moduloHarm*(nh-1)) = a1var.data(nh, 1) + a1var.data(nh, 2)*sqrt(-1);	
						lp.b1(idx+moduloHarm*(nh-1)) = b1var.data(nh, 1) + b1var.data(nh, 2)*sqrt(-1);
						lp.a2(idx+moduloHarm*(nh-1)) = a2var.data(nh, 1) + a2var.data(nh, 2)*sqrt(-1);
						lp.b2(idx+moduloHarm*(nh-1)) = b2var.data(nh, 1) + b2var.data(nh, 2)*sqrt(-1);

						lp.V1_DC(idx+moduloHarm*(nh-1)) = V1var.data(1, 1);	
						lp.I1_DC(idx+moduloHarm*(nh-1)) = I1var.data(1, 1);
						lp.V2_DC(idx+moduloHarm*(nh-1)) = V2var.data(1, 1);
						lp.I2_DC(idx+moduloHarm*(nh-1)) = I2var.data(1, 1);
					end
				else
					lp.a1(idx) = a1var.data(1, 1) + a1var.data(1, 2)*sqrt(-1);				
					lp.b1(idx) = b1var.data(1, 1) + b1var.data(1, 2)*sqrt(-1);
					lp.a2(idx) = a2var.data(1, 1) + a2var.data(1, 2)*sqrt(-1);
					lp.b2(idx) = b2var.data(1, 1) + b2var.data(1, 2)*sqrt(-1);
					
					lp.V1_DC(idx) = V1var.data(1, 1);
					lp.I1_DC(idx) = I1var.data(1, 1);
					lp.V2_DC(idx) = V2var.data(1, 1);
					lp.I2_DC(idx) = I2var.data(1, 1);
				end
				
				% Populate 'props' from bdata cell
				for bi = 1:numel(obj.bdata{idx})
					
					% If index recognized as a1, a2, b1, b2, skip it
					if any(bi == [a1idx, a2idx, b1idx, b2idx, V1idx, I1idx, V2idx, I2idx])
						continue
					end
					
					lpvar = obj.bdata{idx}(bi);
					
					% Continue until harmonic number is reported (this will
					% indicate main data block instead of parameters)
					if contains(lpvar.name, "harm")
						continue;
					end
					
					% Capture frequency in dedicated vector rather than
					% 'props'
					if contains(lpvar.name, "F1") || contains(upper(lpvar.name), "FREQ")
						if removeHarmonics
							lp.freq(idx) = lpvar.data(1, 1);
						else
							for nh = 1:nharm
								lp.freq(idx+moduloHarm*(nh-1)) = lpvar.data(1, 1)*harmNo(nh);
							end
						end
					end
					
					% Else save to 'props'
					lp.props.(AWRLPmdf.fieldName(lpvar.name))(idx) = lpvar.data(1, 1);
					
				end
% 
% 				% Rename known properties
% 				lpp.formatData();
% 				
% 				% Add LPPoint to LPSweep.data
% 				lp.data = addTo(lp.data, lpp);
				
			end
			
			% Populate 'props' from global data
			for g = obj.gdata

				% Skip known to be unhelpful parameters
				if contains(g.name, "NHARM") || contains(g.name, "index")
					continue;
				end
				
				% If characteristic impedance, save to dedicated array
				if contains(g.name, "Z0")
% 					lp.Z0 = zeros(1, len) + g.data(1,1) + sqrt(-1)*g.data(1, 2);
					lp.Z0 = g.data(1,1) + sqrt(-1)*g.data(1, 2);
					continue;
				end

				% Capture frequency in dedicated vector rather than
				% 'props'
				if contains(g.name, "F1") || contains(upper(g.name), "FREQ")
					if removeHarmonics
						lp.freq(1:moduloHarm) = g.data(1, 1);
					else
						for nh = 1:nharm
							lp.freq(1+moduloHarm*(nh-1):moduloHarm*(nh)) = repmat(g.data(1, 1)*harmNo(nh), 1, moduloHarm);
						end
					end
				end
				
				% Else save to props
				if numel(g.data) == 1
					lp.props.(AWRLPmdf.fieldName(g.name)) = zeros(1, len)+g.data;
				else
					lp.props.(AWRLPmdf.fieldName(g.name)) = zeros(1, len)+g.data(1, 1) + sqrt(-1)*g.data(1, 2);
				end

			end
						
		end
		
	end
	
	methods(Static)
		
		function assignedVars = matchData2Vars(words, vars)
		% Takes a list of stringIdxs in 'words' and a list of AWRLPvars in 'vars'
		% and based on the size of data req'd by each var, assigns data to
		% the vars from 'words'

			% Check sizes match
			expectedSize = 0;
			for v = vars
				expectedSize = expectedSize + v.size;
			end
			if expectedSize ~= length(words)
				error("Number of words does not match requirement of given variables.");
			end
			
			% Assign values to variables
			widx = 1;
			for vidx = 1:length(vars)
				
				assignVals = [];
				for wd = words(widx:widx+vars(vidx).size-1)
					assignVals = addTo(assignVals, wd.str);
				end
				
				vars(vidx).assign(assignVals);

				widx = widx + vars(vidx).size;
				
			end
			
			assignedVars = vars;
			
		end
		
		function n = fieldName(n)
			
			n = strrep(n, "(0)", "");
			n = strrep(n, "(1)", "");
			n = strrep(n, "(2)", "");
			n = strrep(n, "(3)", "");
			
		end
		
	end
	
	
end