function idx=findtok(input, pattern, varargin)
% FINDTOK Searches for a pattern within a string, and returns the position
% of the pattern's start if it is not contained within double quotes. This
% is useful for finding tokens such as comment identifiers that are not
% contained within strings
%
%	IDX = FINDTOK(INPUT, PATTERN) Searches for PATTERN in INPUT and returns
%	the starting position of the first character of the first instance of 
%	PATTERN not contained within double quotes. Returns empty set if none
%	found.
%
%	IDX = FINDTOK(INPUT, PATTERN, LOC) Searches for PATTERN in INPUT and 
%	returns the starting position of the first character of the selected
%	instance of PATTERN not contained within double quotes. LOC selects
%	where the first of last such pattern selects which match is returned.
%	Options for LOC are 'First' and 'Last'. Returns empty set if none
%	found.
%
%	See also getString, strfind.

	first = -1;
	last = -1;

	input = char(input);
	pattern = char(pattern);
	
	% Find pattern matches in input
	idxs = strfind(input, pattern);
	
	% Return early if not found
	if isempty(idxs)
		idx = [];
		return;
	end
	
	% Find string locations in input
	sl = stringlocs(input);
	
	% Return early if not found
	if isempty(idxs)
		idx = [];
		return;
	end
	
	% For each match, check if it is in a string
	for i=idxs
		
		notInString = true;
		
		%For each string pair, check if it is within that pair
		for p = sl
			
			% If a < i < b....
			if i > p.a && i < p.b
				notInString = false;
				break	
			end
			
		end
		
		%IF it was not found within any pair...
		if notInString
			
			%Record as first if none prior
			if first == -1
				first = i;
			end
			
			%Update last
			last = i;
		end
		
		useLast = false;
		if nargin > 2
			try
				if upper(string(varargin{1})) == "LAST"
					useLast = true;
				end
			catch
				%kwargs(3) was not a string! Ignoring it.
			end
		end
		
		if first == -1
			idx = [];
		elseif useLast
			idx = last;
		else
			idx = first;
		end
		
	end