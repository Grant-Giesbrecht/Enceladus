function bs = barstr(str, linechar, starter, ender, width, pad)

	% Make sure input is string
	str = string(str);

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
	
	% Pad string if requested
	if pad
		str = " " + str + " ";
	end
	
	pad_back = false;
	while strlength(str) < width-2
		
		if pad_back
			str = str + linechar;
		else
			str = linechar + str;
		end
		pad_back = ~pad_back;
	end
	
	str = starter + str + ender;
	
	bs = str;
	
% 	if ~exist('linechar', 'var')
% 		linechar = '*';
% 	end
% 	
% 	if ~exist('starter', 'var')
% 		linechar = linechar;
% 	end
% 	
% 	if ~exist('ender', 'var')
% 		linechar = linechar;
% 	end
	
	

end