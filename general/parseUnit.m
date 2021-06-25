function [mult, baseUnit] = parseUnit(unit_str)

		unit_str = char(unit_str);

		%Get multiplier
		mult = 1;
		unitStart = 2;
		if unit_str(1) == 'f'
			mult = 1e-15;
		elseif unit_str(1) == 'p'
			mult = 1e-12;
		elseif unit_str(1) == 'n'
			mult = 1e-9;
		elseif unit_str(1) == 'u' %TODO: what is mu character is sent?
			mult = 1e-6;
		elseif unit_str(1) == 'm'
			mult = 1e-3;
		elseif unit_str(1) == 'K' || unit_str(1) == 'k'
			mult = 1e3;
		elseif unit_str(1) == 'M' ||(length(unit_str) >= 3 && strcmp(unit_str(1:3), 'meg'))
			mult = 1e6;
			if length(unit_str) >= 3 && strcmp(unit_str(1:3), 'meg')
				unitStart = 4;
			end
		elseif unit_str(1) == 'G'
			mult = 1e9;
		elseif unit_str(1) == 'T'
			mult = 1e12;
		elseif unit_str(1) == 'E'
			mult = 1e15;
		else
			unitStart = 1;
		end
		
		baseUnit = unit_str(unitStart:end);

end