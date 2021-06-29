function [str, scaled_val, scaled_unit] = scaleNumUnit(value, unit, varargin)

	p = inputParser;
	p.addParameter('DecimalPlaces', -1, @isnumeric);
	p.parse(varargin{:});
	
	

	% Ensure working with base value and unit
	[mult, baseUnit] = parseUnit(unit);
	value = value * mult;
	
	% Determine multiplier
	mult = log10(value);
	
	% Find correct unit scaler
	if mult >= 12
		scaled_unit = strcat("T", baseUnit);
		scaled_val = value / 1e12;
	elseif mult >= 9
		scaled_unit = strcat("G", baseUnit);
		scaled_val = value / 1e9;
	elseif mult >= 6
		scaled_unit = strcat("M", baseUnit);
		scaled_val = value / 1e6;
	elseif mult >= 3
		scaled_unit = strcat("k", baseUnit);
		scaled_val = value / 1e3;
	elseif mult >= 0
		scaled_unit = baseUnit;
		scaled_val = value;
	elseif mult >= -3
		scaled_unit = strcat("m", baseUnit);
		scaled_val = value / 1e-3;
	elseif mult >= -6
		scaled_unit = strcat("u", baseUnit);
		scaled_val = value / 1e-6;
	elseif mult >= -9
		scaled_unit = strcat("n", baseUnit);
		scaled_val = value / 1e-9;
	elseif mult >= -12
		scaled_unit = strcat("p", baseUnit);
		scaled_val = value / 1e-12;
	elseif mult >= -15
		scaled_unit = strcat("f", baseUnit);
		scaled_val = value / 1e-15;
	else
		scaled_unit = baseUnit;
		scaled_val = value;
	end
	
	if p.Results.DecimalPlaces >= 0
		num_str = num2str(scaled_val, strcat("%.",string(p.Results.DecimalPlaces),"f"));
	else
		num_str = num2str(scaled_val);
	end
	
	str = strcat(num_str, " ", scaled_unit);
	
end