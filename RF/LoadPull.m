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
		comp_Gain
		
		dependencies
		current
		tracked
		
		%********** Organizational Info ***************************
		
		sort_info
		
		%********* Repeat Warning Info ****************************
		
		sent_pae_source_value_warning
		
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
			obj.comp_Gain = [];
			
			% Create 'current' as an empty list of strings.
			% 'current' is a list of all tracked values with values that
			% are up-to-date/current.
			obj.current = "";
			obj.current(1) = [];
			
			obj.tracked = ["GAMMA", "P_LOAD", "Z_L", "PAE", "P_IN", "P_DC", "DRAIN_EFF", "GAIN"]; %List of all values tracked for currency. Same as function names but capitolized
			
			% 'dependencies' is a struct. The field name indicates a
			% tracked value, the value is a list of other tracked values
			% upon which the field-name is dependent. (ie. GAMMA is
			% dependent on Z_L
			obj.dependencies = [];
			obj.dependencies.GAMMA = ["Z_L"];
			obj.dependencies.PAE = ["P_IN", "P_LOAD", "P_DC"];
			obj.dependencies.DRAINEFF = ["P_LOAD", "P_DC"];
			obj.dependencies.GAIN = ["P_IN", "P_LOAD"];
			
			unsorted = {};
			unsorted.name = "base";
			unsorted.regions = [1, -1];
			obj.sort_info = [unsorted];
			
			sent_pae_source_value_warning = false;
		end
		
		function merge(obj, varargin)
		% MERGE Merge data from multiple LoadPull objects
		%
		% Merges the data from one or more additional LoadPull objects into
		% the current LoadPull object.
		%
		%	MERGE( LP, ...) Accepts 1 or more LoadPull objects as arguments
		%	and adds their base (non-derived) parameters to this object,
		%	then resets this object. 
		%
		% See also: AWRLPmdf
		
			% Loop over all input objects
			argno = 0;
			for vci = 1:nargin-1
				
				% Convert from cell to argument type
				v = varargin{vci};
				
				% Increment counter
				argno = argno + 1;
				
				% Verify that argument is a LoadPull 
				if ~isa(v, 'LoadPull')
					warning("Cannot merge type '" + class(v) + "' with LoadPull.");
					continue;
				end
				
				if v.numpoints() == 0
					warning("Skipping argument No.: " + argno + " because it contains no data.");
					continue;
				end
				
				% Check that props agree
				if obj.numpoints() ~= 0 && ~isequal(fieldnames(obj.props), fieldnames(v.props))
					warning("Cannot merge LoadPull (Argument No.: " + argno + ") because props structs do not match fields.");
					continue;
				end
				
				np = obj.numpoints();
				
				% Mark object as not current
				obj.reset();
				
				% Update base parameters
				obj.freq = [obj.freq, v.freq];
				obj.Z0 = [obj.Z0, v.Z0];
				
				obj.a1 = [obj.a1, v.a1];
				obj.b1 = [obj.b1, v.b1];
				obj.a2 = [obj.a2, v.a2];
				obj.b2 = [obj.b2, v.b2];
				
				obj.V1_DC = [obj.V1_DC, v.V1_DC];
				obj.I1_DC = [obj.I1_DC, v.I1_DC];
				obj.V2_DC = [obj.V2_DC, v.V2_DC];
				obj.I2_DC = [obj.I2_DC, v.I2_DC];
				
				if np > 0
					for fc = string(fieldnames(v.props))'
						f = fc{:};
						obj.props.(f) = [obj.props.(f), v.props.(f)];
					end
				else
					for fc = string(fieldnames(v.props))'
						f = fc{:};
						obj.props.(f) = v.props.(f);
					end
				end
				
			end
			
			
		end
		
		%==================================================================
		%====             Sort and Filter Functions                    ====
		%==================================================================
		
		function nlp = gfilter(obj, idxs, varargin)
		% GFILTER Filters points and returns a LoadPull object
		%
		% Equivilent to a call of filter() followed by get(). See
		% documentation for LoadPull.filter() for argument options.
		%
		% See also: filter, get
		
			i = obj.filter(idxs, varargin{:});
			nlp = obj.get(i);
		end
		
		function nlp = glistfilter(obj, idxs, varargin)
		% GLISTFILTER Filters points and returns a LoadPull object
		%
		% Equivilent to a call of filter() followed by get(). See
		% documentation for LoadPull.filter() for argument options.
		%
		% See also: listfilter, get, filter
		
			i = obj.listfilter(idxs, varargin);
			nlp = obj.get(i);
		end
		
		function idx_filt = filter(obj, idxs, varargin) %===================================
		% FILTER Filters points based on a set of rules
		%
		% Filters the points in the LoadPull class based on a set of filter
		% commands. 
		%
		%	IDX_FILT = FILTER(..., Name, Value) Filters all points in the
		%	LoadPull class based on the filter commands formulated by the
		%	Name Value pairs. Returns the indecies of the matching points.
		%
		%	IDX_FILT = FILTER(IDXS, ..., Name, Value) Filters the data 
		%	points in the LoadPull class specified by IDXS, based on filter
		%	commands forumulated by the Name Value pairs. Returns the
		%	indecies of the matching points. 
		%
		%	====================== Parameter Naming =====================
		%	To filter the LoadPull object, the user must specify which
		%	paramter to filter. A valid parameter name is the name of any
		%	base parameter (such as Z0, a1, b1, V1_DC, etc.), any derived
		%	parameter (such as PAE, P_in, gamma, etc), or a field in the
		%	property struct. To specify fields in the property struct, the
		%	field name must be preceeded with "props.". The naming is not 
		%	case sensitive and ignores underscores.
		%	
		%	========================= Filter Values =======================
		%	Filter values describe what value a parameter must have in 
		%	order to meet the filter condition. Filter values can be:
		%		
		%		EXACT MATCH: Specified as a scalar value
		%		RANGE: Specified as a 1x2 vector of [MIN, MAX], inclusive.
		%		
		%		GREATER/LESS THAN: Specified as a 1x2 vector of [MIN, MAX],
		%		with the unbounded side specified as NaN.
		%		
		%		MAX/MIN: Returns the points with the highest or lowest
		%		values. Specify a max or min filter values with the strings
		%		"MAX" or "MIN".
		%
		%	===================== Name, Value Pairs =====================
		%
		%	NAME: MinMaxCount
		%	VALUE: Valid values include any positive integer. Specifies how
		%	many values to consider valid when filtering the max/min
		%	points. For example, a filter 'max' with a MinMaxCount of 3
		%	takes the top three values present and returns all indecies
		%	pointing to those values. More than three indecies can be
		%	returned if duplicate values of one of the max values exist.
		%	DEFUALT: 1
		%	
		%	NAME: <Parameter>
		%	VALUE: Value to filter for parameter. See Filter values and
		%	parameter naming above for syntax rules.
		%
		% See also: listfilter()

			% FIlter syntax:
			% * "max" "min" are valid options, case insensitive
			% * Otherwise numeric input expected. If single number, will
			% look for exact match. If two numbers, will look for bound. 
			% If two numbers are given, either one can be made NaN to
			% indicate no limit, and thus greater than/less than. This will
			% be inclusive bounds. 
			% lp.filter("PAE", "max", "PLOAD", [.19, .21], "freq", 10e9);
			
			% Check if idxs provided, if not merge into varargin
			if ~isnumeric(idxs)
				varargin = {idxs, varargin{:}};
				idxs = 1:obj.numpoints();
			end
			
			
			plotArgs = varargin;
			maxmin_count = 1;
			
			% Check that correct number of arguments were given11
			if mod(numel(plotArgs), 2) ~= 0
				warning("LoadPull.filter() Requires an even number of arguments.");
				return;
			end
			
			% Scan through filter list and parse commands
			commands_ns.name = "";
			commands_ns.operation = "";
			commands_ns.value = [];
			commands_ns.mmcount = 1;
			commands_ns(1) = [];
			pop_idx = 1;
			for fi = 1:2:length(plotArgs)
				
				% Handle MinMaxArg 
				if strcmp(plotArgs{fi}, 'MinMaxCount')
					maxmin_count = plotArgs{fi+1};
					continue;
				end
				
				com = {};
				com.name = plotArgs{fi};
				com.mmcount = -1;
				
				v = plotArgs{fi+1};
				if isnumeric(v)
					
					[r, ~] = size(v);
					if r > 1
						warning("Value for filter paramter '" + com.name + "' has multiple rows. To filter using list targets, use listfilter().");
					end
					
					if length(v) == 1
						com.operation = "EQUAL";
						com.value = v;
					elseif isnan(v(1)) && ~isnan(v(2))
						com.operation = "LESS";
						com.value = v(2);
					elseif isnan(v(2)) && ~isnan(v(1))
						com.operation = "GREATER";
						com.value = v(1);
					elseif ~isnan(v(1)) && ~isnan(v(2))
						com.operation = "RANGE";
						com.value = v;
					end
				elseif isa(v, 'string') || isa(v, 'char')
					v = upper(v);
					if strcmp(v, "MAX")
						com.operation = "MAX";
						com.value = [];
					elseif strcmp(v, "MIN")
						com.operation = "MIN";
						com.value = [];
					else
						try
							warning("Failed to recognize command: "+com.name+" = " + string(v));
						catch
							warning("Failed to recognize command: "+com.name+" = <Class: "+class(v) + ">");
						end
						continue;
					end
				else
					try
						warning("Failed to recognize command: "+com.name+" = " + string(v));
					catch
						warning("Failed to recognize command: "+com.name+" = <Class: "+class(v) + ">");
					end
					continue;
				end
				
				% Add to command list
				commands_ns(end+1) = com;
				pop_idx = pop_idx+1;
				
			end
			
% 			filtcom.name = "PAE"
% 			fitcom.operation = {"MAX", "MIN", "Equal", "GREATER", "LESS"}
% 			fitcom.value
			
			% Re-order the filter commands so they give top-level sorted
			% parameter precedence over non-sorted or lower-level sorted
			% parameters. Also all max and min commands must go to end
			if length(obj.sort_info) > 1 % Only sort if object was organized
				Is = zeros(1, length(commands_ns));
				sort_names = upper([obj.sort_info(2:end).name]);
				count = 0;
				for fc = commands_ns % Loop over all filter commands

					% Increment counter
					count = count + 1;
					
					if strcmp(fc.operation, "MAX") || strcmp(fc.operation, "MIN")
						Is(count) = inf;
						continue;
					end
					
					% Check if parameter was sorted
					if any(upper(fc.name) == sort_names)
						Is(count) = find(upper(fc.name) == sort_names);
					else
						Is(count) = inf;
					end
				end
				[~, I_filt] = sort(Is); % Determine precedence of filter commands
				commands = commands_ns(I_filt); % Rearrange filter commands
			else % Else keep as-is
				
				Is = zeros(1, length(commands_ns));
				count = 0;
				for fc = commands_ns % Loop over all filter commands
					
					% Increment counter
					count = count  + 1;
					
					if strcmp(fc.operation, "MAX") || strcmp(fc.operation, "MIN")
						Is(count) = inf;
					else
						Is(count) = 1;
					end
				end
				
				[~, I_filt] = sort(Is); % Determine precedence of filter commands
				commands = commands_ns(I_filt); % Rearrange filter commands
			end
			% Note: returns indecies (and can accept indecies as an
			% optional parameter). To get a LoadPull object feed indecies
			% into LoadPull.getLP() function.
			
			% For each filter command
			for cmd = commands
				
				% Update mmcount
				cmd.mmcount = maxmin_count;
			
				%TODO: Remove this! filterLienar and continue are used as a
				%simple test.
				idxs = obj.filterLinear(idxs, idxs, cmd);
				continue;
				
				% Filter indecies ------------------
				
				% Check if parameter is sorted
				if any(cmd.name == sort_names) % Found, do binary searches where possible
					
					% Get sort regions (from higher order parameter in
					% sort_info). Mutliply by indecies
					si_idx = find(cmd.name == sort_names);
					regions = obj.sort_info(si_idx-1).regions;
					
					% Remove sort_regions from other indecies
					lin_idxs = idxs;
					[rows, ~] = size(regions);
					for ridx = 1:rows
						
						% Find end index
						if regions(ridx, 2) == -1
							end_idx = obj.numpoints();
						else
							end_idx = regions(ridx, 2);
						end
						
						% Remove indecies
						rmve = regions(ridx, 1):end_idx;
						lin_idxs(rmve) = [];
					end
					
					
					% Remove all mismatch indecies in ea. sort region
					for reg = regions 
						idxs = filterSortRegion(reg, idxs, cmd);
					end
					
					% Remove all mismatch indecies from linear regions
					idxs = filterLinear(lin_idxs, idxs, cmd);
					
				else % Not found, do linear search
					
					% Remove all mismatch indecies (100% linear search)
					idxs = filterLinear(idxs, idxs, cmd);
					
				end	
			
			end
			
			idx_filt = idxs;
			
		end %======================== END FILTER ==========================
		
		function idx_filt = listfilter(obj, idxs, varargin) %==============
		% LISTFILTER Filters parameters to match a list of changing values
		%
		% Filters the points in the LoadPull class based on a set of filter
		% commands. 
		%
		%	IDX_FILT = FILTER(..., Name, Value) Filters all points in the
		%	LoadPull class based on the filter commands formulated by the
		%	Name Value pairs. Returns the indecies of the matching points.
		%
		%	IDX_FILT = FILTER(IDXS, ..., Name, Value) Filters the data 
		%	points in the LoadPull class specified by IDXS, based on filter
		%	commands forumulated by the Name Value pairs. Returns the
		%	indecies of the matching points. 
		%
		%	====================== Parameter Naming =====================
		%	To filter the LoadPull object, the user must specify which
		%	paramter to filter. A valid parameter name is the name of any
		%	base parameter (such as Z0, a1, b1, V1_DC, etc.), any derived
		%	parameter (such as PAE, P_in, gamma, etc), or a field in the
		%	property struct. To specify fields in the property struct, the
		%	field name must be preceeded with "props.". The naming is not 
		%	case sensitive and ignores underscores.
		%	
		%	========================= Filter Values =======================
		%	Filter values describe what value a parameter must have in 
		%	order to meet the filter condition. Filter values can be:
		%		
		%		EXACT MATCH: Specified as a scalar value
		%		RANGE: Specified as a nx2 vector of [MIN, MAX], inclusive.
		%		
		%		GREATER/LESS THAN: Specified as a nx2 vector of [MIN, MAX],
		%		with the unbounded side specified as NaN.
		%		
		%		MAX/MIN: Returns the points with the highest or lowest
		%		values. Specify a max or min filter values with the strings
		%		"MAX" or "MIN".
		%
		%		Note on Vector Dimensions:
		%		All vectors must have the same number of rows, as each
		%		row's values will be filtered independently of the other
		%		rows, then merged together. The only exception is that 1x2
		%		vectors are accepted as well. Filter commands specifies as
		%		1x2 vectors will be applied equally to all 'n' rows.
		%
		%	===================== Name, Value Pairs =====================
		%
		%	NAME: MinMaxCount
		%	VALUE: Valid values include any positive integer. Specifies how
		%	many values to consider valid when filtering the max/min
		%	points. For example, a filter 'max' with a MinMaxCount of 3
		%	takes the top three values present and returns all indecies
		%	pointing to those values. More than three indecies can be
		%	returned if duplicate values of one of the max values exist.
		%	DEFUALT: 1
		%	
		%	NAME: <Parameter>
		%	VALUE: Value to filter for parameter. See Filter values and
		%	parameter naming above for syntax rules.
		%
		% See also: filter() 
		
			
			expectedDomain = {'Z', 'G'};
			expectedSchemes = {'Light', 'Dark'};

			p = inputParser;
			p.KeepUnmatched = true;
			p.addParameter('Sort', false, @islogical );
			try
				p.parse(varargin{:});
				do_sort = p.Results.Sort;
				
				% Get plot arguments
				tmp = [fieldnames(p.Unmatched),struct2cell(p.Unmatched)];
				varargin_rem = reshape(tmp',[],1)';
			catch
				do_sort = false;
				varargin_rem = varargin;
			end
			
			
			
			
			% Filter syntax:
			% * "max" "min" are valid options, case insensitive
			% * Otherwise numeric input expected. If single number, will
			% look for exact match. If two numbers, will look for bound. 
			% If two numbers are given, either one can be made NaN to
			% indicate no limit, and thus greater than/less than. This will
			% be inclusive bounds. 
			% lp.filter("PAE", "max", "PLOAD", [.19, .21], "freq", 10e9);
			
			% Check if idxs provided, if not merge into varargin_rem
			if ~isnumeric(idxs)
				varargin_rem = {idxs, varargin_rem{:}};
				idxs = 1:obj.numpoints();
			end
			
			% Check that correct number of arguments were given11
			if mod(numel(varargin_rem), 2) ~= 0
				warning("LoadPull.filter() Requires an even number of arguments.");
				return;
			end
			
			% Check that inputs have correct length
			len = 1;
			showed_warning = false;
			for fi = 1:2:length(varargin_rem)
				
				% Find size of input argument
				[r, c] = size(varargin_rem{fi+1});
				
				% Show warning for possibly incorrectly oriented inputs
				if c > 2 && ~showed_warning
					warning("listfilter received argument with more than two columns. Perhaps you meant to transpose the input vector?");
				end
				
				% 1 row always okay
				if r == 1
					continue;
				end
				
				if len == 1
					len = r;
				elseif len ~= r
					warning("All input lists must have the same number of rows!");
					return;
				end
			end
			
			all_idxs = [];
			check_idxs = idxs;
			for i=1:len
				
				% Make copy of input arguments with one row of data
				args_in = varargin_rem;
				for fi = 2:2:length(varargin_rem)
					[r, ~] = size(varargin_rem{fi});
					if r ~= 1
						args_in{fi} = args_in{fi}(i,:);
					end
				end
				
				% Filter row data
				new_idxs = obj.filter(check_idxs, args_in{:});
				
				% Add to master list
				all_idxs = [all_idxs, new_idxs];
				
			end
			
			% Return sorted master list
			if do_sort
				idx_filt = unique(sort(all_idxs));
			else
				idx_filt = unique(all_idxs);
			end
			
		end
		
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
				I = [1:start_idx-1, I+start_idx-1, end_idx+1:length(array)];
				
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

		function lp = get(obj, idxs, varargin)
		% GET Returns a LoadPull object with filtered data.
		%
		%	LP = GET(IDXS) Returns a LoadPull object with all populated
		%	data arrays filter to only contain the data points at the
		%	indecies listed in IDXS.
		%
		%	See also: filter
			
			lp = LoadPull;
			
			if ~isempty(obj.freq)
				lp.freq = obj.freq(idxs);
			end
			if ~isempty(obj.Z0)
				lp.Z0 = obj.Z0;
			end
			if ~isempty(obj.a1)
				lp.a1 = obj.a1(idxs);
			end
			if ~isempty(obj.b1)
				lp.b1 = obj.b1(idxs);
			end
			if ~isempty(obj.a2)
				lp.a2 = obj.a2(idxs);
			end
			if ~isempty(obj.b2)
				lp.b2 = obj.b2(idxs);
			end
			if ~isempty(obj.V1_DC)
				lp.V1_DC = obj.V1_DC(idxs);
			end
			if ~isempty(obj.I1_DC)
				lp.I1_DC = obj.I1_DC(idxs);
			end
			if ~isempty(obj.V2_DC)
				lp.V2_DC = obj.V2_DC(idxs);
			end
			if ~isempty(obj.I2_DC)
				lp.I2_DC = obj.I2_DC(idxs);
			end
			flds = ccell2mat(fields(obj.props));
			for f = flds
				lp.props.(f) = obj.props.(f)(idxs);
			end
			
% 			lp.sort_info = obj.sort_info;
			
		end
		
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
				val = obj.p_load();
			elseif name == "PAE"
				val = obj.pae();
			elseif name == "GAMMA"
				val = obj.gamma();
			elseif name == "PDC"
				val = obj.p_dc();
			elseif name == "PIN"
				val = obj.p_in();
			elseif name == "ZL"
				val = obj.z_l();
			elseif name == "DRAINEFF"
				val = obj.drain_eff();
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
		% FINDREGIONS For an array array, finds all regions of matching
		% values. alloc_size sets how many cells are allocated to the
		% output array at a time (larger = faster. Defualt = len/10).
			
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
		
		function rearrange(obj, I, surpressLengthIWarning)
		% REARRANGE Rearrange all populated parameters in the object
		%
		%	 REARRANGE(I) Shuffles all arrays in the object according to I.
		%	 ie. applies x = x(I) s.t. x is every populated array in the
		%	 object (ie. derived parameters, base parameters, and fields of
		%	 props).
		%
		% See also: organize()
		
			if ~exist('surpressLengthIWarning', 'var')
				surpressLengthIWarning = false;
			end

			expected = obj.numpoints();
		
			if length(I) ~= expected && ~surpressLengthIWarning
				warning("Length of input indecies has incorrect length!");
			end
			
% 			% Determine expected length
% 			expected = length(I);
			
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
		
		function [vals, stdevs, bins] = average(obj, idxs, avg_prop, varargin)
		% AVERAGE Calculates the average value for an array of indecies
		%
		%	[vals, stdevs, bins] = AVERAGE(AVG_PROP, ... Name, Value)
		%	AVG_PROP is the name of the property to average. It is case
		%	insensitive and can refer to any derived or base parameter,
		%	including fields of props. The Name Value pairs are list filter
		%	commands. For each row in the Values, the matching points will
		%	be analyzed and their averages and standard deviations will be
		%	returned in 'vals' and 'stdevs', respectively. bins will
		%	contain all rows of the input filter command Values that had
		%	one or more points match.
		%
		%	[vals, stdevs, bins] = average(IDXS, ...) Can specify the
		%	indecies to check over as an optional first parameter. If not
		%	specified, all indecies will be checked.
		%
		%	See also: filter, listfilter
		
			% Check for optional argument idxs
			if ~isnumeric(idxs)
				varargin = {avg_prop, varargin{:}};
				avg_prop = idxs;
				idxs = 1:obj.numpoints();
			end
			
			% Initialize arrays
			[pts, ~] = size(varargin{2});
			vals = zeros(1, pts);
			stdevs = zeros(1, pts);
			
			pop_idxs = [];
			
			bins = {varargin{2:2:length(varargin)}};
			
			% Get average/stdev for each point
			for idx = 1:pts
				
				% Get filter arguments for this point
				args = varargin;
				for vi = 2:2:numel(varargin)
					
					% Check if multiple rows of arguments given
					[rs, ~] = size(args{vi});
					if rs > 1
						args{vi} = args{vi}(idx, :); % Trim values to one row
					end
				end
				
				% Get indecies
				pt_idxs = obj.filter(idxs, args{:});
				
				% Handle no points match condition
				if isempty(pt_idxs)
					pop_idxs(end+1) = idx;
					continue;
				end
				
				% Get data to average
				data = obj.getArrayFromName(avg_prop);
				
				% Compute values
				vals(idx) = mean(data(pt_idxs));
				stdevs(idx) = std(data(pt_idxs));
				
% 				if isnan(stdevs(idx)) || isnan(vals(idx))
% 					displ("~");
% 				end
				
			end
			
			% Remove missing values
			vals(pop_idxs) = [];
			stdevs(pop_idxs) = [];
			for bidx = 1:length(bins)
				bins{bidx}(pop_idxs, :) = [];
			end
			
		end
		
% 		function idx_filt = filterSortRegion(obj, filt_idxs, idxs, cmd)
% 			
% 			idx_filt = idxs;
% 			
% 			% Get array to filter
% 			array = obj.getArrayFromName(cmd.name);
% 			array = array(filt_idxs);
% 			
% 			if strcmp(cmd.operation, "MAX")
% 				match_idx = max(array);
% 			elseif strcmp(cmd.operation, "MIN")
% 				match_idx = min(array);
% 			elseif strcmp(cmd.operation, "EQUAL")
% 				match_idx = (array == cmd.value);
% 			elseif strcmp(cmd.operation, "GREATER")
% 				match_idx = (array >= cmd.value);
% 			elseif strcmp(cmd.operation, "LESS")
% 				match_idx = (array <= cmd.value);
% 			elseif strcmp(cmd.operation, "RANGE")
% 				match_idx = (array >= cmd.value(1) && array <= cmd.value(2));
% 			end
% 			
% 			% Find indecies to remove
% 			rmve_idx = filt_idxs(match_idx);
% 			
% 			% Remove from master list
% 			idx_filt(rmve_idx) = [];
% 		end
		
		function idx_out = filterLinear(obj, filt_idxs, idxs, cmd)
		
			
			% Get array to filter
			array = obj.getArrayFromName(cmd.name);
			array = array(filt_idxs);
			
			if strcmp(cmd.operation, "MAX")
				
				% Make copy of array for eliminating values without
				% affecting indecies
				max_array = array;
				
				% Create array of all 'false'
				match_idx = num2logical(zeros(1, length(array)));
				
				% For each 'max', find next highest point
				for mv = 1:cmd.mmcount
					maxval = max(max_array); % Find max
					if isempty(maxval) % Quit early if find all points
						break;
					end
					match_idx = match_idx | (array == maxval); % Save where max occurs
					max_array(max_array == maxval) = []; % Remove maxes from list
				end
			elseif strcmp(cmd.operation, "MIN")
				match_idx = [];
				for mv = 1:cmd.mmcount
					minval = min(array);
					if isempty(minval) % Quit early if find all points
						break;
					end
					match_idx = [match_idx, (array == minval)];
					if ~isempty(match_idx)
						array(find(match_idx)) = [];
					end
				end
			elseif strcmp(cmd.operation, "EQUAL")
				match_idx = (array == cmd.value);
			elseif strcmp(cmd.operation, "GREATER")
				match_idx = (array >= cmd.value);
			elseif strcmp(cmd.operation, "LESS")
				match_idx = (array <= cmd.value);
			elseif strcmp(cmd.operation, "RANGE")
				match_idx = (array >= cmd.value(1) & array <= cmd.value(2));
			end
			
			% Find indecies to remove
			rmve_idx = filt_idxs(~match_idx);
			
			% Remove from master list
			idx_out = setdiff(idxs, rmve_idx);
% 			idx_out(rmve_idx) = [];
		end
		
		function len = numpoints(obj)
		% NUMPOINTS Returns the number of points in the data arrays.
		%
		%	LEN = NUMPOINTS() Returns teh number of points in the object's
		%	data arrays.
		%
		%	See also: reset()
		
			len = 0;
			if ~isempty(obj.freq)
				len = length(obj.freq);
			elseif ~isempty(obj.a1)
				len = length(obj.a1);
			elseif ~isempty(obj.b1)
				len = length(obj.b1);
			elseif ~isempty(obj.a2)
				len = length(obj.a2);
			elseif ~isempty(obj.b2)
				len = length(obj.b2);
			elseif ~isempty(obj.V1_DC)
				len = length(obj.I1_DC);
			elseif ~isempty(obj.V2_DC)
				len = length(obj.I2_DC);
			end
		end
		
		function showorg(obj)
		% SHOWORG Display the organizational structure of the object
			
			displ("Sort Info:");
			idx = 0;
			for si = obj.sort_info
				displ("  [", idx, "] Layer: ", si.name);
				if ~isempty(si.regions)
					displ("      Regions: ");

					[rows, ~] = size(si.regions);
					for r = 1:rows
						displ("               [", si.regions(r, 1), ", ", si.regions(r, 2), "]"); 
					end
				else
					displ("      Regions: NONE");
				end
				idx = idx + 1;
			end
			
		end
		
		%==================================================================
		%====        Functions for Calculating Derived Parameters      ====
		%==================================================================
		
		function v = gamma(obj) %==========================================
		%GAMMA Return the reflection coefficient
		%
		%	V = GAMMA() Returns the reflection coefficient
		%
		%	See also: p_load
			
			% Make sure data is up to date
			if ~obj.isCurrent("GAMMA")
				obj.comp_gamma = ab2gamma(obj.a2, obj.b2);
				obj.setCurrent("GAMMA")
			end
			
			% Return value
			v = obj.comp_gamma;
		end %============================ END GAMMA =======================
		
		function v = p_out(obj, units)
		% P_OUT Return output power. Alternative name for function
		% p_load. See p_load help for argument details.
		%
		%	See also: p_load, p_in
			
			% Check for optional arguments
			if ~exist('units', 'var')
				units = "dBm";
			end
			
			v = obj.p_load(units);
			
		end
		
		function v = p_load(obj, units) %==================================
		%P_LOAD Return the RF power delivered to the load
		%
		%	V = P_LOAD() Returns the power delivered to the load
		%
		%	V = P_LOAD(Units) Returns the power delivered to the load in
		%	the specified units. Options are 'dBm' and 'W'
		%
		%	See also: p_out, p_in
			
			%Check for optional arguments
			if ~exist('units', 'var')
% 				units = "dBm";
				units = 'W';
			else
				units = string(units);
			end
		
			% Make sure data is up to date
			if ~obj.isCurrent("P_LOAD")
				
				% Equation from Pozar (4th ed.) eq. 4,62. NOTE: I flipped a
				% & b because I think Pozar is using an unconventional
				% description of a vs. b.
				obj.comp_Pload = 0.5 .* abs(obj.b2).^2 - 0.5 .* abs(obj.a2).^2;
				
				obj.setCurrent("P_LOAD");
			end
			
			% Get value
			v = obj.comp_Pload;
			
 			% Perform conversion
			if contains(units, "dB", 'IgnoreCase', true)
				v = lin2dB(v.*1e3, 10); % Base 10 log conversion
			end
			
		end %=========================== END P_LOAD =======================
		
		function v = p_in(obj) %===========================================
		% P_IN Return the RF power input to the system
		%
		%	V = P_IN() Return the RF power input.
		%
		%	See also: p_dc
		
			% Make sure data is up-to-date
			if ~obj.isCurrent("P_IN")
				
				% Taken from p_load function and modified to work for input
				obj.comp_Pin = 0.5 .* abs(obj.a1).^2 - 0.5 .* abs(obj.b1).^2;
				
				obj.setCurrent("P_IN");
			end
			
			v = obj.comp_Pin;
			
		end %=========================== END P_IN =========================
		
		function v = p_dc(obj) %===========================================
		% P_DC Return the DC power input to the system.
		%
		%	V = P_DC Return the DC power input to the system.
		%
		%	See also: z_l
		
		
			if ~obj.isCurrent("P_DC")
				obj.comp_Pdc = abs(obj.V1_DC .* obj.I1_DC) + abs(obj.V2_DC .* obj.I2_DC);				
				obj.setCurrent("P_DC");
			end
			
			v = obj.comp_Pdc;
			
		end %=========================== END P_DC =========================
		
		function v = z_l(obj) %==========================================
		% Z_L Returns the load impedances.
		%
		%	V = Z_L Calculates the load impedances in ohms.
		%
		%	See also: pae
		
		
			if ~obj.isCurrent("Z_L")
				% NOTE: USes calls to gamma to make sure gamma is current
				obj.comp_ZL = obj.Z0 .* (1 + obj.gamma())./(1 - obj.gamma());
				obj.setCurrent("Z_L");
			end
			
			% Return value
			v = obj.comp_ZL;
		end %========================== END Z_L ===========================
		
		function v = pae(obj) %============================================
		% PAE Returns the power added efficiency
		%
		%	V = PAE() Returns the power added efficiency in percent.
		%	
		%	See also: gain
			
			if ~obj.isCurrent("PAE")
				obj.comp_PAE = 100.*(abs(obj.p_load()) - abs(obj.p_in()))./obj.p_dc;
				if any(obj.comp_PAE > 100)  %TODO: Is there a better way to handle such sanity checks?
					if ~obj.sent_pae_source_value_warning
						warning("Provided power data is incorrect. PAE calculated to be > 100%. Setting terms to 100%.");
						obj.sent_pae_source_value_warning = true;
					end
					obj.comp_PAE(obj.comp_PAE > 100) = 100;
				end
				
				obj.setCurrent("PAE");
				
				%TODO: Make this cleaner
				obj.comp_PAE(obj.comp_PAE > 100) = 100;
			end
			
			% Return value
			v = obj.comp_PAE;
			
		end %========================== END PAE ===========================
		
		function v = gain(obj)
		% GAIN Returns the gain of the system.
		%
 		%	V = GAIN() Returns the gain of the system.
		%
		%	See also: drain_eff
		
			if ~obj.isCurrent("GAIN")
				obj.comp_Gain = lin2dB(obj.p_load()./obj.p_in());
				obj.setCurrent("GAIN");
			end
			
			% Return value
			v = obj.comp_Gain;
			
		end
		
		function v = drain_eff(obj) %=======================================
		% DRAIN_EFF Returns the drain efficiency.
		%
		%	V = DRAIN_EFF() Returns the drain efficiency.
		%
		%	See also: gamma
		
			if ~obj.isCurrent("DRAIN_EFF")
				obj.comp_DrainEff = 100.* abs(obj.p_load() ./ obj.p_dc());
				obj.setCurrent("DRAIN_EFF");
			end
			
			v = obj.comp_DrainEff;
			
		end %========================== END DRAINEFF ======================
		
		function N = trimNonphysical(obj) %================================
			
			all_pae = 100.*(abs(obj.p_load()) - abs(obj.p_in()))./obj.p_dc;
			
			keepIdx = find(all_pae <= 100);
			
			N = obj.numpoints() - length(keepIdx);
			
			obj.rearrange(keepIdx, true);
			
		end %========================== TRIMNONPHYSICAL ===================
		
		%==================================================================
		%====              Functions for tracking currency             ====
		%==================================================================
		
		function tf = isCurrent(obj, name) %===============================
		%ISCURRENT Check if a derived parameter is up-to-date
		%
		%	ISCURRENT(NAME) Checks if the parameter 'NAME' is up to date.
		%
		%	See also: reset
		
			tf = any(name == obj.current);
		end %========================== END ISCURRENT =====================
		
		function setCurrent(obj, name, status) %===========================
		% SETCURRENT Update the status of a variable as current or
		% not-current.
		%
		%	SETCURRENT(NAME, STATUS) Specifies the status of the parameter
		%	'NAME' to current or not current. If 'STATUS' is true, sets the
		%	variable to current, otherwise sets to out of date. Updates the
		%	status of dependencies as needed.
		%
		%	See also: Reset
			
			% Check for optional arguments
			if ~exist('status', 'var')
				status = true;
			end
			
			% Convert all to uppercase
			name = upper(name);
			
			% If name is not in list of all tracked variables, quit
			if ~any(name == obj.tracked)
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
		% RESET Marks all derived parameters as out of date.
		%
		%	RESET() Set all derived parameters as out of date, so the next
		%	time they are queried they will be recalculated.
		
			obj.current = "";
			obj.current(1) = [];
			
		end %=================== END RESET ================================
		
	end
	
end