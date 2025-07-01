function barprint(str, linechar, starter, ender, width, pad)

	% Handle optional arguments
	if ~exist('linechar', 'var')
		linechar = '=';
	end
	if ~exist('starter', 'var')
		starter = '[';
	end
	if ~exist('ender', 'var')
		ender = ']';
	end
	if ~exist('width', 'var')
		width = 80;
	end
	if ~exist('pad', 'var')
		pad = true;
	end

	disp(barstr(str, linechar, starter, ender, width, pad));
	
end