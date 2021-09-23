function hlin(y, varargin)
%HLIN	Displays a horizontal line on the current plot. 
%
%	HLIN(Y) Draws a horizontal line at the value specified by Y.
%
%	HLIN(Y, S) Draws a horizontal line at the value specified by Y and
%	applies S, where S is a character string specifying line options. Valid
%	options for S are the same as in the built-in MATLAB function line().
%
%	See also VLIN, LINE.

    xl = xlim;
	
	% If HandleVisibility option is not set, add it as false.
	if ~cellContains(varargin, 'HandleVisibility', true) 
		varargin{end+1} = 'HandleVisibility';
		varargin{end+1} = 'off';
	end
	
    line([xl(1), xl(2)], [y, y], varargin{:});
end