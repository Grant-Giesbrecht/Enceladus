function [tf, idx] = cellContains(cells_in, value, matchCharStr)
	
	idx = -1;

	% Check for optional argument, convertChar
	if ~exist('matchCharStr', 'var')
		matchCharStr = false;
	end
	
	% If match strings and chars, convert input to string if is a char
	if matchCharStr && isa(value, 'char')
		value = string(value);
	end

	tf = false;
	[vr, vc] = size(value);

	% For each item
	idx = 0;
	for cellval = cells_in
		
		idx = idx + 1;
		
		% Get value
		val = cellval{1};
		
		% If match chars and strings and value is a char, convert to
		% strings
		if matchCharStr && isa(val, 'char')
			val = string(val);
		end
		
		% Check, if arrays, that size matches
		[er, ec] = size(val);
		if er ~= vr || ec ~= vc
			continue;
		end
		
		% Not a match if different types
		if class(val) ~= class(value)
			continue;
		end

		% Check if values match
		if val == value
			tf = true;
			return;
		end
		
	end
	
end