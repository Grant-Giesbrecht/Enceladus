classdef AWRLPmdf < handle
	
	properties %====================== Properties =========================
		
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

		% Grid describing 'validity' of data, by which format means length
		% of each variable in a block
		validityGrid
		
		% Message out
		msg
		
	end %==================== END Properties ==============================
	
	methods %=============================== Methods ======================
		
		function obj = AWRLPmdf() %================== Constructor =========
		
			obj.gdata = [];
			obj.bdata = {};
			
			obj.bform = [];
			obj.bTokensPerLine = [];
			
			obj.validityGrid = [];
			
			msg = "";
		end %============================== END Constructor ===============
		
		function tf = load(obj, filename) %=========== Load ===============
			
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
							
							% Use the validity grid to compute the lengths
							if ~obj.runValidityGrid()
								tf = false;
								return;
							end
							
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
						
						% 
						for w = words
							
							
							
						end
						
					otherwise
						error("location variable in invalid state!");
				end
				
				
			end
			
		end %============================== END Load ======================
		
		function tf = runValidityGrid(obj) %======== runValidityGrid ======
			
			tf = true;
			
			% Check grid is correct size
			[r,c] = size(obj.validityGrid);
			if c ~= numel(obj.bform)
				msg = "Validity grid is wrong size.";
				tf = false;
				return;
			end
			
			%TODO: Will currently ignore this grid. Could later use to
			%check file is not broken/mis-interpreted
			
			% purpose is to populate 'validLen' param in AWRLPvar
			
		end %=========================== END runValidityGrid ==============
		
		function s = str(obj) %================ str() =====================
			
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
			
		end %============================= END str() ======================
		
	end %================================= END methods ====================
	
	methods(Static) %================ Static Methods ======================
		
		function assignedVars = matchData2Vars(words, vars) %==============
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
			
		end %=========================== END matchData2Vars ===============
		
	end %========================= END Static Methods =====================
	
	
end