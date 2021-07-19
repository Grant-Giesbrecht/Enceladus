function C = polcomp(mag, arg, varargin)
% POLCOMP Generate a complex number from magnitude and argument
%
%	C = POLCOMP(MAG, ARG) Generate a complex number with magnitude MAG and
%	angle ARG.
%
%	C = POLCOMP(..., Name, Value) specifies conversion properties using the
%	name value pair.
%
%	Name/Value pairs:
%
%		Name: Unit
%		Value: units of input angle ARG. Options: 'radians', 'degrees'
%		Default: radians
%
%	See also: abs, angle, cart2pol

	% Parse input arguments
	expectedUnits = {'radians', 'degrees', 'radian', 'degree', 'rad', 'deg'};
	p = inputParser();
	p.addParameter('Unit', 'radians', @(x) any(validatestring(lower(char(x)), expectedUnits)));
	p.parse(varargin{:});
	
	% Check units, convert to radians if degrees
	usedeg = false;
	if strcmp(p.Results.Unit, 'degrees') || strcmp(p.Results.Unit, 'degree') || strcmp(p.Results.Unit, 'deg')
		arg = arg.*pi./180;
	end
	
	% Calculate complex number
	C = mag.*exp(sqrt(-1).*arg);

end