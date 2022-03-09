function [valf, quant] = cvrt2(val, units0, unitsf)
% CVRT2 Converts between units
%
% Accepts a value and a starting unit and an optional ending unit, and
% converts the value. If no ending unit is specified, SI units are assumed.
%
% 
	units0 = string(units0);
	units0 = upper(units0);
	
	
	if ~exist('unitsf', 'var')
		unitsf = "SI";
	end
	
	unitsf = string(unitsf);
% 	unitsf = upper(unitsf);

	quant = "";
	val_si = 0;
	
	
	% Convert to SI units
	if strcmp(units0, "dBm")			% ------ Power units --------
		quant = "POWER";
		val_si = dB2lin(val, 10)./1e3;
	elseif strcmp(units0, "dBW")
		quant = "POWER";
		val_si = dB2lin(val, 10);
	elseif prefixed(units0, "W")
		quant = "POWER";
		[~,mult,~]=prefixed(units0, "W"); % Get multiplier
		val_si = val.*mult;
	elseif prefixed(units0, "hp")
		quant = "POWER";
		[~,mult,~]=prefixed(units0, "hp"); % Get multiplier
		val_si = val./745.699872; % Mechanical/hydraulic horsepower
	elseif strcmp(units0, "C") %------- Temperature Units ---------
		quant = "TEMPERATURE";
		val_si = val+273.15;
	elseif strcmp(units0, "F")
		quant = "TEMPERATURE";
		val_si = (val-32).*5./9+273.15;
	elseif strcmp(units0, "K")
		quant = "TEMPERATURE";
		val_si = val;
	elseif strcmp(units0, "J") %----------- Energy ---------
		quant = "ENERGY";
		[~,mult,~]=prefixed(units0, "J"); % Get multiplier
		val_si = val.*mult;
	elseif strcmp(units0, "eV")
		quant = "ENERGY";
		[~,mult,~]=prefixed(units0, "eV"); % Get multiplier
		val_si = val.*1.602176565e-19.*mult;
	elseif strcmp(units0, "cal")
		quant = "ENERGY";
		[~,mult,~]=prefixed(units0, "cal"); % Get multiplier
		val_si = val.*4.184.*mult; %calorie, not Calorie or kcal, but 1000 cal = kcal
	elseif strcmp(units0, "BTU")
		quant = "ENERGY";
		val_si = val.* 1055.05585262;
	elseif strcmp(units0, "m") %----------- Length ---------
		quant = "LENGTH";
		[~,mult,~]=prefixed(units0, "m"); % Get multiplier
		val_si = val.*mult;
	elseif strcmp(units0, "mi") %----------- Length ---------
		quant = "LENGTH";
		val_si = val.*1609.344;
	elseif strcmp(units0, "in") %----------- Length ---------
		quant = "LENGTH";
		[~,mult,~]=prefixed(units0, "mi"); % Get multiplier
		val_si = val.*1609.344;
	elseif strcmp(units0, "g") %----------- Weight ---------
		quant = "MASS";
		[~,mult,~]=prefixed(units0, "g"); % Get multiplier
		val_si = val.*mult./1e3;
	elseif strcmp(units0, "lb")
		quant = "MASS";
		val_si = val./2.2046;
	elseif strcmp(units0, "oz")
		quant = "MASS";
		val_si = val.*.02835;
	else
		error("Unit " + unit0 + " not recognized.");
	end
	
	% Convert from SI units to desired units
	if strcmp(unitsf, "SI")
		valf = val_si;
	elseif strcmp(unitsf, "DBM")
		if ~strcmp(quant, "POWER")
			error("Cannot convert units of " + quant + " to units of POWER.");
		end
		valf = lin2dB(val_si.*1e3, 10);
	elseif strcmp(unitsf, "W")
		if ~strcmp(quant, "POWER")
			error("Cannot convert units of " + quant + " to units of POWER.");
		end
		valf = val_si;
	elseif strcmp(unitsf, "DBW")
		if ~strcmp(quant, "POWER")
			error("Cannot convert units of " + quant + " to units of POWER.");
		end
		valf = lin2dB(val_si, 10);
	else
		error("Unit " + unitf + " not recognized.");
	end
	
end