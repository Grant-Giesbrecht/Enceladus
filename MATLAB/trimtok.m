function trimmed = trimtok(input, pattern)
% TRIMTOK Looks for a pattern that does not fall within double quotes and
% if that pattern is found, returns the string up to but not including the
% pattern match.
%
%
	input = char(input);

	%Find token location
	tl = findtok(input, pattern, 'First');
	
	%Return early if none found
	if isempty(tl)
		trimmed = input;
		return;
	end
	
	trimmed = input(1:tl-1);
end