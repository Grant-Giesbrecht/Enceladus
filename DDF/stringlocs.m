function l=stringlocs(input)
% STRINGLOCS Returns indeces of the start and end of everystring within a
% string.
%
%	Returns the indeces in the form of a list of twoples. The twople's 'a'
%	field is populated with the start index of a string section, 'b' with
%	the end index. A twople is placed in the returned list for each string
%	contained in the input.
%
%	L = STRINGLOCS(INPUT) Finds strings, indicated by double quote
%	characters, in INPUT and creates a twople for each string containing
%	the start and end values of the string.
%
%	See also GETSTRING, TWOPLE

	l = [];

	%Set to char array
	input = char(input);
	x = 1;

	while true
		
		% Get strings until all found
		nextStr = getString(input(x:end));
		if isempty(nextStr)
			break;
		end
		
		%Create a twople from the start and end indeces of the string
		t = twople(nextStr.sidx, nextStr.idx);
		x = x + t.b;
		
		%Add to list
		l = addTo(l, t);
		
	end


end