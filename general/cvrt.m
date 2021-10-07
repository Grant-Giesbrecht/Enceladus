function valf = cvrt(val, units0, unitsf)

	units0 = string(units0);
	units0 = upper(units0);
	
	
	if ~exist('unitsf', 'var')
		unitsf = "SI";
	end
	
	unitsf = string(unitsf);
	unitsf = upper(unitsf);

	quant = "";
	val_si = 0;
	
	% Convert to SI units
	if strcmp(units0, "DBM")
		quant = "POWER";
		val_si = dB2lin(val, 10)./1e3;
	elseif strcmp(units0, "W")
		quant = "POWER";
		val_si = val;
	elseif strcmp(units0, "DBW")
		quant = "DBW";
		val_si = dB2lin(val, 10);
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