function [tf, mult, unit]=prefixed(str, base)
% PREFIXED Checks a string to match prefix-unit format
%
%	TF, MULT, UNIT = PREFIXED(str) Checks string for matching the
%	prefix-unit format. Returns tf as boolean for if match found, mult
%	contains the mutliplier to convert values of the original unit to SI
%	base units, and unit contains the base unit's string.
%
%	TF, MULT, UNIT = PREFIXED(str, base) Checks string for matching the
%	prefix-unit format. Returns tf as boolean for if match found, mult
%	contains the mutliplier to convert values of the original unit to SI
%	base units, and unit contains the base unit's string. String must have
%	unit matching input argument 'base' to count as match.
%
%	See also: CVRT

	% Convert all to char
	str = char(str);

	if ~exist('base', 'var')
		base = str(2:end);
	end
	base = char(base);
	
	unit = base;
	
	base_len = numel(base);

	% Check for base mismatch
	if ~strcmp(str(end-base_len+1:end), base)
		tf = false;
		mult = 0;
		return;
	end
	
	% Check for no prefix
	if base_len == numel(str)
		mult = 1;
		tf = true;
		return;
	end
	
	prefix = str(1:end-base_len);
	
	% Check for prefix match
	if strcmp(prefix, "k")
		mult = 1e3;
		tf = true;
		return;
	elseif strcmp(prefix, "M")
		mult = 1e6;
		tf = true;
		return;
	elseif strcmp(prefix, "G")
		mult = 1e9;
		tf = true;
		return;
	elseif strcmp(prefix, "T")
		mult = 1e12;
		tf = true;
		return;
	elseif strcmp(prefix, "P")
		mult = 1e15;
		tf = true;
		return;
	elseif strcmp(prefix, "Y")
		mult = 1e18;
		tf = true;
		return;
	elseif strcmp(prefix, "m")
		mult = 1e-3;
		tf = true;
		return;
	elseif strcmp(prefix, "u")
		mult = 1e-6;
		tf = true;
		return;
	elseif strcmp(prefix, "n")
		mult = 1e-9;
		tf = true;
		return;
	elseif strcmp(prefix, "p")
		mult = 1e-12;
		tf = true;
		return;
	elseif strcmp(prefix, "f")
		mult = 1e-15;
		tf = true;
		return;
	elseif strcmp(prefix, "a")
		mult = 1e-18;
		tf = true;
		return;
	end
	
	mult = 0;
	tf = false;
	return;

end