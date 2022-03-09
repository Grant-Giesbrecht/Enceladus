function [valf, quant] = cvrt2(val, units0, unitsf)
% CVRT2 Converts between units
%
% Accepts a value and a starting unit and an optional ending unit, and
% converts the value. If no ending unit is specified, SI units are assumed.
%
% 
	units0 = string(units0);
% 	units0 = upper(units0);
	
	
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
		val_si = val.*745.699872; % Mechanical/hydraulic horsepower
	elseif strcmp(units0, "C") %------- Temperature Units ---------
		quant = "TEMPERATURE";
		val_si = val+273.15;
	elseif strcmp(units0, "F")
		quant = "TEMPERATURE";
		val_si = (val-32).*5./9+273.15;
	elseif strcmp(units0, "K")
		quant = "TEMPERATURE";
		val_si = val;
	elseif prefixed(units0, "J") %----------- Energy ---------
		quant = "ENERGY";
		[~,mult,~]=prefixed(units0, "J"); % Get multiplier
		val_si = val.*mult;
	elseif prefixed(units0, "eV")
		quant = "ENERGY";
		[~,mult,~]=prefixed(units0, "eV"); % Get multiplier
		val_si = val.*1.602176565e-19.*mult;
	elseif prefixed(units0, "cal")
		quant = "ENERGY";
		[~,mult,~]=prefixed(units0, "cal"); % Get multiplier
		val_si = val.*4.184.*mult; %calorie, not Calorie or kcal, but 1000 cal = kcal
	elseif strcmp(units0, "BTU")
		quant = "ENERGY";
		val_si = val.* 1055.05585262;
	elseif prefixed(units0, "m") %----------- Length ---------
		quant = "LENGTH";
		[~,mult,~]=prefixed(units0, "m"); % Get multiplier
		val_si = val.*mult;
	elseif strcmp(units0, "mi")
		quant = "LENGTH";
		val_si = val.*1609.344;
	elseif strcmp(units0, "in") 
		quant = "LENGTH";
		val_si = val.*.0254;
	elseif strcmp(units0, "yd") 
		quant = "LENGTH";
		val_si = val.*.9144;
	elseif prefixed(units0, "ly")
		quant = "LENGTH";
		[~, mult, ~] = prefixed(units0, "ly");
		val_si = val.*mult.*9.461e15;
	elseif prefixed(units0, "g") %----------- Weight ---------
		quant = "MASS";
		[~,mult,~]=prefixed(units0, "g"); % Get multiplier
		val_si = val.*mult./1e3;
	elseif strcmp(units0, "lb")
		quant = "MASS";
		val_si = val./2.2046;
	elseif strcmp(units0, "oz")
		quant = "MASS";
		val_si = val.*.02835;
	elseif strcmp(units0, "st")
		quant = "MASS";
		val_si = val.*6.35029;
	elseif strcmp(units0, "amu") || prefixed("Da")
		quant = "MASS";
		[~,mult,~]=prefixed(units0, "m"); % Get multiplier
		if mult == 0
			mult = 1;
		end
		val_si = val.*1.66054e-27.*mult;
	elseif prefixed(units0, "Pa") %----------- Pressure ---------
		quant = "PRESSURE";
		[~,mult,~]=prefixed(units0, "Pa"); % Get multiplier
		val_si = val.*mult;
	elseif strcmp(units0, "atm")
		quant = "PRESSURE";
		val_si = val.*101325;
	elseif strcmp(units0, "psi")
		quant = "PRESSURE";
		val_si = val.*6894.76;
	elseif strcmp(units0, "mmHg")
		quant = "PRESSURE";
		val_si = val.*133.322;
	elseif prefixed(units0, "m/s") %----------- Speed ---------
		quant = "SPEED";
		[~,mult,~]=prefixed(units0, "m/s"); % Get multiplier
		val_si = val.*mult;
	elseif strcmp(units0, "kph")
		quant = "SPEED";
		val_si = val.*.277778;
	elseif strcmp(units0, "mph")
		quant = "SPEED";
		val_si = val.*.44704;
	elseif strcmp(units0, "kt") || strcmp(units0, "kn")
		quant = "SPEED";
		val_si = val.*.514444;
	elseif strcmp(units0, "fps")
		quant = "SPEED";
		val_si = val.*.3048;
	else
		error("Unit " + units0 + " not recognized.");
	end
	
	% Convert from SI units to desired units
	if strcmp(unitsf, "SI")
		valf = val_si;
	elseif strcmp(unitsf, "dBm") %------------- Power Units -----------
		if ~strcmp(quant, "POWER")
			error("Cannot convert units of " + quant + " to units of POWER.");
		end
		valf = lin2dB(val_si.*1e3, 10);
	elseif prefixed(unitsf, "W")
		if ~strcmp(quant, "POWER")
			error("Cannot convert units of " + quant + " to units of POWER.");
		end
		[~,mult,~]=prefixed(unitsf, "W"); % Get multiplier
		valf = val_si./mult;
	elseif strcmp(unitsf, "dBW")
		if ~strcmp(quant, "POWER")
			error("Cannot convert units of " + quant + " to units of POWER.");
		end
		valf = lin2dB(val_si, 10);
	elseif strcmp(unitsf, "hp")
		if ~strcmp(quant, "POWER")
			error("Cannot convert units of " + quant + " to units of POWER.");
		end
		valf = val_si.*.00134102;
	elseif strcmp(unitsf, "C") %---------- Temperature Units -------------
		if ~strcmp(quant, "TEMPERATURE")
			error("Cannot convert units of " + quant + " to units of TEMPERATURE.");
		end
		valf = val_si-273.15;
	elseif strcmp(unitsf, "F")
		if ~strcmp(quant, "TEMPERATURE")
			error("Cannot convert units of " + quant + " to units of TEMPERATURE.");
		end
		valf = (val_si-273.14).*9./5+32;
	elseif strcmp(unitsf, "K")
		if ~strcmp(quant, "TEMPERATURE")
			error("Cannot convert units of " + quant + " to units of TEMPERATURE.");
		end
		valf = (val_si-273.14).*9./5+32;
	elseif prefixed(unitsf, "J") %---------- Energy Units -------------
		if ~strcmp(quant, "ENERGY")
			error("Cannot convert units of " + quant + " to units of ENERGY.");
		end
		[~,mult,~]=prefixed(unitsf, "J"); % Get multiplier
		valf = val_si./mult;
	elseif prefixed(unitsf, "eV")
		if ~strcmp(quant, "ENERGY")
			error("Cannot convert units of " + quant + " to units of ENERGY.");
		end
		[~,mult,~]=prefixed(unitsf, "eV"); % Get multiplier
		valf = val_si./1.602176565e-19./mult;
	elseif prefixed(unitsf, "cal")
		if ~strcmp(quant, "ENERGY")
			error("Cannot convert units of " + quant + " to units of ENERGY.");
		end
		[~,mult,~]=prefixed(unitsf, "cal"); % Get multiplier
		valf = val_si./4.184./mult; %calorie, not Calorie or kcal, but 1000 cal = kcal
	elseif strcmp(unitsf, "BTU")
		if ~strcmp(quant, "ENERGY")
			error("Cannot convert units of " + quant + " to units of ENERGY.");
		end
		valf = val_si./1055.05585262;
	elseif prefixed(unitsf, "m") %---------- Length Units -------------
		if ~strcmp(quant, "LENGTH")
			error("Cannot convert units of " + quant + " to units of LENGTH.");
		end
		[~,mult,~]=prefixed(unitsf, "m"); % Get multiplier
		valf = val_si./mult;
	elseif strcmp(unitsf, "mi")
		if ~strcmp(quant, "LENGTH")
			error("Cannot convert units of " + quant + " to units of LENGTH.");
		end
		valf = val_si./1609.344;
	elseif strcmp(unitsf, "in")
		if ~strcmp(quant, "LENGTH")
			error("Cannot convert units of " + quant + " to units of LENGTH.");
		end
		valf = val_si./.0254;
	elseif strcmp(unitsf, "yd")
		if ~strcmp(quant, "LENGTH")
			error("Cannot convert units of " + quant + " to units of LENGTH.");
		end
		valf = val_si./.9144;
	elseif prefixed(unitsf, "ly")
		if ~strcmp(quant, "LENGTH")
			error("Cannot convert units of " + quant + " to units of LENGTH.");
		end
		[~,mult,~]=prefixed(unitsf, "ly"); % Get multiplier
		valf = val_si./9.461e15./mult;
	elseif prefixed(unitsf, "g") %---------- Mass Units -------------
		if ~strcmp(quant, "MASS")
			error("Cannot convert units of " + quant + " to units of MASS.");
		end
		[~,mult,~]=prefixed(unitsf, "m"); % Get multiplier
		valf = val_si./mult.*1e3;
	elseif strcmp(unitsf, "lb")
		if ~strcmp(quant, "MASS")
			error("Cannot convert units of " + quant + " to units of MASS.");
		end
		valf = val_si.*2.2046;
	elseif strcmp(unitsf, "oz")
		if ~strcmp(quant, "MASS")
			error("Cannot convert units of " + quant + " to units of MASS.");
		end
		valf = val_si./.02835;
	elseif strcmp(unitsf, "st")
		if ~strcmp(quant, "MASS")
			error("Cannot convert units of " + quant + " to units of MASS.");
		end
		valf = val_si./6.35029;
	elseif strcmp(unitsf, "amu") || prefixed(unitsf, "Da")
		if ~strcmp(quant, "MASS")
			error("Cannot convert units of " + quant + " to units of MASS.");
		end
		[~,mult,~]=prefixed(unitsf, "Da"); % Get multiplier
		if mult == 0
			mult = 1;
		end
		valf = val_si./1.66054e-27./mult;
	elseif prefixed(unitsf, "Pa") %---------- Pressure Units -------------
		if ~strcmp(quant, "PRESSURE")
			error("Cannot convert units of " + quant + " to units of PRESSURE.");
		end
		[~,mult,~]=prefixed(unitsf, "Pa"); % Get multiplier
		valf = val_si./mult;
	elseif strcmp(unitsf, "atm")
		if ~strcmp(quant, "PRESSURE")
			error("Cannot convert units of " + quant + " to units of PRESSURE.");
		end
		valf = val_si./101325;
	elseif strcmp(unitsf, "psi")
		if ~strcmp(quant, "PRESSURE")
			error("Cannot convert units of " + quant + " to units of PRESSURE.");
		end
		valf = val_si./6894.76;
	elseif strcmp(unitsf, "mmHg")
		if ~strcmp(quant, "PRESSURE")
			error("Cannot convert units of " + quant + " to units of PRESSURE.");
		end
		valf = val_si./133.322;
	elseif prefixed(unitsf, "m/s") %---------- Speed Units -------------
		if ~strcmp(quant, "SPEED")
			error("Cannot convert units of " + quant + " to units of SPEED.");
		end
		[~,mult,~]=prefixed(unitsf, "m/s"); % Get multiplier
		valf = val_si./mult;
	elseif strcmp(unitsf, "kph") 
		if ~strcmp(quant, "SPEED")
			error("Cannot convert units of " + quant + " to units of SPEED.");
		end
		valf = val_si./277778;
	elseif strcmp(unitsf, "mph") 
		if ~strcmp(quant, "SPEED")
			error("Cannot convert units of " + quant + " to units of SPEED.");
		end
		valf = val_si./44704;
	elseif strcmp(unitsf, "kt") || strcmp(unitsf, "kn")
		if ~strcmp(quant, "SPEED")
			error("Cannot convert units of " + quant + " to units of SPEED.");
		end
		valf = val_si./.514444;
	elseif strcmp(unitsf, "fps") 
		if ~strcmp(quant, "SPEED")
			error("Cannot convert units of " + quant + " to units of SPEED.");
		end
		valf = val_si./3048;
	

	elseif prefixed(units0, "m/s") %----------- Speed ---------
		quant = "SPEED";
		[~,mult,~]=prefixed(units0, "m/s"); % Get multiplier
		val_si = val.*mult;
	elseif strcmp(units0, "kph")
		quant = "SPEED";
		val_si = val.*.277778;
	elseif strcmp(units0, "mph")
		quant = "SPEED";
		val_si = val.*.44704;
	elseif strcmp(units0, "kt") || strcmp(units0, "kn")
		quant = "SPEED";
		val_si = val.*.514444;
	elseif strcmp(units0, "fps")
		quant = "SPEED";
		val_si = val.*.3048;
	else
		error("Unit " + unitsf + " not recognized.");
	end
	
end