classdef LoadPull < handle
% LOADPULL Class for storing, computing, and sorting load pull data
%
% 
	
	properties
		
		%************* Base Parameters (Not Derived) *********************
		
		freq
		Z0
		
		a1
		b1
		a2
		b2
		
		V1_DC
		I1_DC
		V2_DC
		I2_DC
		
		props
		
		%************ Derived Parameters (Calculated from Base) **********
		
		comp_Pload
		comp_PAE
		comp_gamma
		comp_Pdc
		comp_Pin
		comp_ZL
		comp_DrainEff
		
		dependencies
		current
		tracked
		
		%********** Organizational Info ***************************
		
		sort_info
		
	end
	
	methods
		
		function obj = LoadPull(obj)
			
			% Check for optional parameter Z0
			if ~exist('Z0', 'var')
				Z0 = 50;
			end
			
			obj.freq = [];
			obj.Z0 = Z0;

			obj.a1 = [];
			obj.b1 = [];
			obj.a2 = [];
			obj.b2 = [];

			obj.V1_DC = [];
			obj.I1_DC = [];
			obj.V2_DC = [];
			obj.I2_DC = [];

			obj.props = {};
			
			
			
			obj.comp_Pload = [];
			obj.comp_PAE = [];
			obj.comp_gamma = [];
			obj.comp_Pdc = [];
			obj.comp_Pin = [];
			obj.comp_ZL = [];
			obj.comp_DrainEff = [];
			
			
			% Create 'current' as an empty list of strings.
			% 'current' is a list of all tracked values with values that
			% are up-to-date/current.
			obj.current = "";
			obj.current(1) = [];
			
			obj.tracked = ["GAMMA", "P_LOAD", "Z_L", "PAE", "P_IN", "P_DC", "DRAIN_EFF"]; %List of all values tracked for currency. Same as function names but capitolized
			
			% 'dependencies' is a struct. The field name indicates a
			% tracked value, the value is a list of other tracked values
			% upon which the field-name is dependent. (ie. GAMMA is
			% dependent on Z_L
			obj.dependencies = [];
			obj.dependencies.GAMMA = ["Z_L"];
			obj.dependencies.PAE = ["P_IN", "P_LOAD", "P_DC"];
			obj.dependencies.DRAINEFF = ["P_LOAD", "P_DC"];
			
			unsorted = {};
			unsorted.name = "base";
			unsorted.regions = [1, -1];
			obj.sort_info = [unsorted];
		end
		
		%==================================================================
		%====             Sort and Filter Functions                    ====
		%==================================================================
		
		function filter(obj, varargin) %===================================
			
			% Re-order the filter commands so they give top-level sorted
			% parameter precedence over non-sorted or lower-level sorted
			% parameters.
			
			% Note: returns indecies (and can accept indecies as an
			% optional parameter). To get a LoadPull object feed indecies
			% into LoadPull.getLP() function.
			
			% For each filter command
			
				% Filter indecies
				
				% Return indecies
			
		end %======================== END FILTER ==========================
		
		function organize(obj, varargin) %=================================
		% ORGANIZE Organizes the data such that searching is faster
		%
		% Accepts a list of property names as strings (ex. 'PAE',
		% 'props.iPower', etc. etc) and sorts each in ascending order,
		% subdivided by the higher priority item
		%
		
		% TODO: Add function to show organization summary including avg
		% number of points per region at each sort-level to indicate if the
		% class is over-sorted, sorting by a bad parameter, or undersorted.
		
		sort_list = ccell2mat(varargin);
% 		sort_list = ["freq", "props.iPower", "PAE"];
				
		% For each thing in sort list...
		for sp = sort_list
		
			% For each sort region...
			[rows, ~] = size(obj.sort_info(end).regions);
			for ridx = 1:rows
				
				% Get sort region indecies
				start_idx = obj.sort_info(end).regions(ridx, 1);
				end_idx = obj.sort_info(end).regions(ridx, 2);
				
				% Get array data to sort
				array = obj.getArrayFromName(sp);
			
				% Check for region ends at end of array (-1)
				if end_idx == -1
					end_idx = numel(array);
				end
				
				% Sort array. Only keep suffle indecies
				[~, I] = sort(array(start_idx:end_idx));
				
				% Add missing indecies from outside the sort region
				I = [1:start_idx-1, I, end_idx+1:length(array)];
				
				% Reshuffle all arrays
				obj.rearrange(I);
				
			end
			
			% Calculate new sort regions
			array = obj.getArrayFromName(sp); % Get freshly sorted parameter
			nsi = {};
			nsi.name = sp;
			nsi.regions = obj.findregions(array);
			
			% Save sort_regions for each sort parameter into global
			% variable
			obj.sort_info = [obj.sort_info, nsi];
			
		end
		% Globally saved:
		% 1. Sorted data
		% 2. Sort_info structs (in array)
		%	I. Sort parameter name (s.name)
		%   II. Sort regions for parameter (s.regions)
			
		end %======================== END ORGANIZE ========================

		function val = getArrayFromName(obj, name)
		% GETARRAYFROMNAME Returns the value of an internal array by its
		% string name.
		
			% Naming system is case-insensitive and does
			% not regard underscores. 'comp_' is not used.
			name_orig = name;
			name = upper(name);
			name = strrep(name, "_", "");
			
			if name == "FREQ"
				val = obj.freq;
			elseif name == "A1"
				val = obj.a1;
			elseif name == "B1"
				val = obj.b1;
			elseif name == "A2"
				val = obj.a2;
			elseif name == "B2"
				val = obj.b2;
			elseif name == "V1DC"
				val = obj.V1_DC;
			elseif name == "I1DC"
				val = obj.I1_DC;
			elseif name == "V2DC"
				val = obj.V2_DC;
			elseif name == "PLOAD"
				val = obj.comp_Pload;
			elseif name == "PAE"
				val = obj.comp_PAE;
			elseif name == "GAMMA"
				val = obj.comp_gamma;
			elseif name == "PDC"
				val = obj.comp_Pdc;
			elseif name == "PIN"
				val = obj.comp_Pin;
			elseif name == "ZL"
				val = obj.comp_ZL;
			elseif name == "DRAINEFF"
				val = obj.comp_DrainEff;
			elseif contains(name, "PROPS.")
				
				% Get field name
				name = char(name_orig);
				name = name(7:end);
				
				% Verify field exists
				if ~isfield(obj.props, name)
					warning("Failed to find property '"+name+"'");
					val = NaN;
					return;
				end
				
				% Return field
				val = obj.props.(name);
			else
				warning("Failed to find property '" + name + "'");
				val = NaN;
				return;
			end
			
			
		end
		
		function tf = setArrayFromName(obj, name, val)
		% SETARRAYFROMNAME Updates the value of an internal array by its
		% string name.
		
			% Naming system is case-insensitive and does
			% not regard underscores. 'comp_' is not used.
			name = upper(name);
			name = strrep(name, "_", "");
			
			tf = true;
			
			if name == "FREQ"
				obj.freq = val;
			elseif name == "A1"
				obj.a1 = val;
			elseif name == "B1"
				obj.b1 = val;
			elseif name == "A2"
				obj.a2 = val;
			elseif name == "B2"
				obj.b2 = val;
			elseif name == "V1DC"
				obj.V1_DC = val;
			elseif name == "I1DC"
				obj.I1_DC = val;
			elseif name == "V2DC"
				obj.V2_DC = val;
			elseif name == "PLOAD"
				obj.comp_Pload = val;
			elseif name == "PAE"
				obj.comp_PAE = val;
			elseif name == "GAMMA"
				obj.comp_gamma = val;
			elseif name == "PDC"
				obj.comp_Pdc = val;
			elseif name == "PIN"
				obj.comp_Pin = val;
			elseif name == "ZL"
				obj.comp_ZL = val;
			elseif name == "DRAINEFF"
				obj.comp_DrainEff = val;
			elseif contains(name, "props.")
				
				% Get field name
				name = char(name);
				name = name(6:end);
				
				% Verify field exists
				if ~isfield(obj.props, name)
					warning("Failed to find property '"+name+"'");
					tf = false;
					return;
				end
				
				% Return field
				obj.prop.(name) = val;
			else
				warning("Failed to find property '" + name + "'");
				tf = false;
			end
			
		end
		
		function sr = findregions(obj, array, alloc_size)
			
			% Handle optional arguments
			if ~exist('alloc_size', 'var');
				% Make a guess for how many regions to provide
				alloc_size = numel(array)/10;
			end
			
			% Find sort regions
			deltas = diff(array);
			deltas(end+1) = 1; % Add a 'end of match region' symbol to take care of any matched regions aligned with end

			sort_regions = zeros(alloc_size, 2);
			sz = alloc_size;
			count = 1;
			in_region = false;
			start_idx = -1;
			for didx = 1:numel(deltas)

				if deltas(didx) == 0
					if ~in_region % Found beginning of region
						in_region = true;
						start_idx = didx;
					end
				elseif in_region % Found end of region
					in_region = false;

					% Add to region list
					sort_regions(count,:) = [start_idx, didx];
					count = count + 1;

					% Check if need to reallocate sort_regions
					if count > sz
						sort_regions = [sort_regions; zeros(alloc_size, 2)];
						sz = sz + alloc_size;
					end
				end

			end

			% Trim sort_regions to correct size
			sr = sort_regions(1:count-1,:);
		end
		
		function rearrange(obj, I)
			
			% Determine expected length
			expected = length(I);
			
			if ~isempty(obj.freq)
				if length(obj.freq) ~= expected
					warning("Variable 'freq' has incorrect length!");
				end
				obj.freq = obj.freq(I);
			end
			if ~isempty(obj.a1)
				if length(obj.a1) ~= expected
					warning("Variable 'a1' has incorrect length!");
				end
				obj.a1 = obj.a1(I);
			end
			if ~isempty(obj.b1)
				if length(obj.b1) ~= expected
					warning("Variable 'b1' has incorrect length!");
				end
				obj.b1 = obj.b1(I);
			end
			if ~isempty(obj.a2)
				if length(obj.a2) ~= expected
					warning("Variable 'a2' has incorrect length!");
				end
				obj.a2 = obj.a2(I);
			end
			if ~isempty(obj.b2)
				if length(obj.b2) ~= expected
					warning("Variable 'b2' has incorrect length!");
				end
				obj.b2 = obj.b2(I);
			end
			if ~isempty(obj.V1_DC)
				if length(obj.V1_DC) ~= expected
					warning("Variable 'V1_DC' has incorrect length!");
				end
				obj.V1_DC = obj.V1_DC(I);
			end
			if ~isempty(obj.I1_DC)
				if length(obj.I1_DC) ~= expected
					warning("Variable 'I1_DC' has incorrect length!");
				end
				obj.I1_DC = obj.I1_DC(I);
			end
			if ~isempty(obj.V2_DC)
				if length(obj.V2_DC) ~= expected
					warning("Variable 'V2_DC' has incorrect length!");
				end
				obj.V2_DC = obj.V2_DC(I);
			end
			if ~isempty(obj.I2_DC)
				if length(obj.I2_DC) ~= expected
					warning("Variable 'I2_DC' has incorrect length!");
				end
				obj.I2_DC = obj.I2_DC(I);
			end
			
			if ~isempty(obj.comp_Pload)
				if length(obj.comp_Pload) ~= expected
					warning("Variable 'comp_Pload' has incorrect length!");
				end
				obj.comp_Pload = obj.comp_Pload(I);
			end
			if ~isempty(obj.comp_PAE)
				if length(obj.comp_PAE) ~= expected
					warning("Variable 'comp_PAE' has incorrect length!");
				end
				obj.comp_PAE = obj.comp_PAE(I);
			end
			if ~isempty(obj.comp_gamma)
				if length(obj.comp_gamma) ~= expected
					warning("Variable 'comp_gamma' has incorrect length!");
				end
				obj.comp_gamma = obj.comp_gamma(I);
			end
			if ~isempty(obj.comp_Pdc)
				if length(obj.comp_Pdc) ~= expected
					warning("Variable 'comp_Pdc' has incorrect length!");
				end
				obj.comp_Pdc = obj.comp_Pdc(I);
			end
			if ~isempty(obj.comp_Pin)
				if length(obj.comp_Pin) ~= expected
					warning("Variable 'comp_Pin' has incorrect length!");
				end
				obj.comp_Pin = obj.comp_Pin(I);
			end
			if ~isempty(obj.comp_ZL)
				if length(obj.comp_ZL) ~= expected
					warning("Variable 'comp_ZL' has incorrect length!");
				end
				obj.comp_ZL = obj.comp_ZL(I);
			end
			if ~isempty(obj.comp_DrainEff)
				if length(obj.comp_DrainEff) ~= expected
					warning("Variable 'comp_DrainEff' has incorrect length!");
				end
				obj.comp_DrainEff = obj.comp_DrainEff(I);
			end

			% Repeat for all 'props'
			for f = fields(obj.props)
				
				pname = f{:};
				
				if ~isempty(obj.props.(pname))
					if length(obj.props.(pname)) ~= expected
						warning("Variable 'props."+pname+"' has incorrect length!");
					end
					arr = obj.props.(pname);
					obj.props.(pname) = arr(I);
				end
				
			end
			
		end
		
		
		function showorg(obj)
			
			displ("Sort Info:");
			idx = 0;
			for si = obj.sort_info
				displ("  [", idx, "] Layer: ", si.name);
				displ("      Regions: ");
				
				[rows, ~] = size(si.regions);
				for r = 1:rows
					displ("               [", si.regions(r, 1), ", ", si.regions(r, 2), "]"); 
				end
			end
			
		end
		
		%==================================================================
		%====        Functions for Calculating Derived Parameters      ====
		%==================================================================
		
		function v = gamma(obj) %==========================================
		%GAMMA Return the reflection coefficient
			
			% Make sure data is up to date
			if ~obj.isCurrent("GAMMA")
				obj.comp_gamma = ab2gamma(obj.a2, obj.b2);
				obj.setCurrent("GAMMA")
			end
			
			% Return value
			v = obj.comp_gamma;
		end %============================ END GAMMA =======================
		
		function v = p_load(obj) %=========================================
		%P_LOAD Calculate power delivered to the load
			
			% Make sure data is up to date
			if ~obj.isCurrent("P_LOAD")
				
				% Equation from Pozar (4th ed.) eq. 4,62. NOTE: I flipped a
				% & b because I think Pozar is using an unconventional
				% description of a vs. b.
				obj.comp_Pload = 0.5 .* abs(obj.b2).^2 - 0.5 .* abs(obj.a2).^2;
				
				obj.setCurrent("P_LOAD");
			end
			
			% Return value
			v = obj.comp_Pload;
		end %=========================== END P_LOAD =======================
		
		function v = p_in(obj) %===========================================
			
			% Make sure data is up-to-date
			if ~obj.isCurrent("P_IN")
				
				% Taken from p_load function and modified to work for input
				obj.comp_Pin = 0.5 .* abs(obj.a1).^2 - 0.5 .* abs(obj.b1).^2;
				
				obj.setCurrent("P_IN");
			end
			
			v = obj.comp_Pin;
			
		end %=========================== END P_IN =========================
		
		function v = p_dc(obj) %===========================================
			
			if ~obj.isCurrent("P_DC")
				obj.comp_Pdc = abs(obj.V1_DC .* obj.I1_DC) + abs(obj.V2_DC .* obj.I2_DC);				
				obj.setCurrent("P_DC");
			end
			
			v = obj.comp_Pdc;
			
		end %=========================== END P_DC =========================
		
		function v = z_l(obj) %==========================================
		% Converts the load pull gammas to impedances
		
			if ~obj.isCurrent("Z_L")
				% NOTE: USes calls to gamma to make sure gamma is current
				obj.comp_ZL = obj.Z0 .* (1 + obj.gamma())./(1 - obj.gamma());
				obj.setCurrent("Z_L");
			end
			
			% Return value
			v = obj.comp_ZL;
		end %========================== END Z_L ===========================
		
		function v = pae(obj) %============================================
			
			if ~obj.isCurrent("PAE")
				obj.comp_PAE = 100.*(abs(obj.p_load()) - abs(obj.p_in()))./obj.p_dc;
				obj.setCurrent("PAE");
			end
			
			% Return value
			v = obj.comp_PAE;
			
		end %========================== END PAE ===========================
		
		function v = drain_eff(obj) %=======================================
			
			if ~obj.isCurrent("DRAIN_EFF")
				obj.comp_DrainEff = 100.* abs(obj.p_load() ./ obj.p_dc());
				obj.setCurrent("DRAIN_EFF");
			end
			
			v = obj.comp_DrainEff;
			
		end %========================== END DRAINEFF ======================
		
		%==================================================================
		%====              Functions for tracking currency             ====
		%==================================================================
		
		function tf = isCurrent(obj, name) %===============================
		%ISCURRENT Check if a variable is current
			tf = any(name == obj.current);
		end %========================== END ISCURRENT =====================
		
		function setCurrent(obj, name, status) %===========================
		% SETCURRENT Update the status of a variable as current or
		% not-current
		%
		% If status=true, sets to up-to-date, if false, to out-of-date.
			
			% Check for optional arguments
			if ~exist('status', 'var')
				status = true;
			end
			
			% Convert all to uppercase
			name = upper(name);
			
			% If name is not in list of all tracked variables, quit
			if ~any(name == obj.current_tracked)
				warning("Invalid tracking name.");
				return;
			end
			
			% Update status
			if status % Add to current
				if ~any(obj.current == name)
					obj.current = addTo(obj.current, name);
				end
			else % Remove from current
				if any(obj.current == name)
					idx = find(obj.current==name, 1, 'first');
					obj.current(idx) = [];
				end
			end
			
			% Go through dependencies and update their statuses if top
			% level status was set to out-of-date
			if ~status && isfield(obj.dependencies, name)
				
				% Scan through all dependencies and set to out-of-date
				for d = obj.dependencies.(name)
					obj.setCurrent(d, false);
				end
				
			end
			
		end %=================== END SETCURRENT ===========================
		
		function reset(obj) %==============================================
			
			obj.current = "";
			obj.current(1) = [];
			
		end %=================== END RESET ================================
		
	end
	
end