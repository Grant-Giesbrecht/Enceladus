function s = num2estr(x)

	% Get original formatting options
	fmt = format;
	
	% Change global formatting to engineerig mode
	format short eng
	
	% Get string
	s = strtrim(evalc('disp(x)'));
	s = trimzeros(s);
	
	% Reset formatting options
	format(fmt);

end