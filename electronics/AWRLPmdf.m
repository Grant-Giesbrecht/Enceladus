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
		end
		
		function tf = load(obj, filename)
			
			tf = true;
			
			%Open file
            fid = fopen(filename);
			if fid == -1
				obj.logErr(strcat('Failed to open file "', filename, '"'));
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
						
						% Block index refers to the line of the data block,
						% NOT the index of the variable being assigned
						blockIdx = blockIdx + 1;
						
						% Check that correct number of tokens/values are
						% one this line of the file
						if length(words) ~= obj.bTokensPerLine(blockIdx)
							tf = false;
							obj.msg = "Data block on line" + num2str(lnum) + "is the wrong size!";
							return;
						end
						
						% Copy bform into new data array
						data = [];
						for bd = obj.bform
							data = addTo(data, bd);
						end
						
						for w = words
							
							
							
						end
						
					otherwise
						error("location variable in invalid state!");
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
		
			%************ Calculate Tokens Per Line, Without accounting for
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
						obj.bTokensPerLine(bIdx) = count;
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
				obj.bTokensPerLine(bIdx) = count;
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
		
	end
	
	
end