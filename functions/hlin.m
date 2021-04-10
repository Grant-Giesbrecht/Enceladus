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
    line([xl(1), xl(2)], [y, y], varargin{:});
end