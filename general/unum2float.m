function [vals, unit]=unum2float(vec)
	
	units = [];
	vals = [];
	
	lastUnit = "";
	isFirst = true;
	index = 0;
	
	for v=vec
		
		index = index + 1;
		
		words = parseIdx(v, strcat(" ", char(9)));
		
		%Skip blank lines
		if isempty(words)
			continue;
		end
		
		%If only one word preset, try to add spaces around possible units
		if length(words) ~= 2
			cv = char(v);
			numsAndDecimals = bitor(isstrprop(string(v),'digit'), (cv == '.'));
			lastNumeric = find(numsAndDecimals, 1, 'last');
			
			%Handle unitless values
			if lastNumeric == length(v)
				vals = NaN;
			unit = NaN;
				return; %TODO: Could add code here to handle unitless values
			end
			
			%If next character is not a space, add one
			if ~isspace(cv(lastNumeric+1))
				cv = [cv(1:lastNumeric), ' ', cv(lastNumeric+1:end)];
				disp(strcat("Automatically added space between value and unit (Idx: ", string(index), " New String: '", string(cv), "')."));
				
				%Retry parsing
				words = parseIdx(string(cv), strcat(" ", char(9)));
			end
			
		end
		
		%Ensure 2 words present
		if length(words) ~= 2
			disp(strcat("Found incorrect number of words. (Idx: ", string(index), " Input: '", v, "')."));
			vals = NaN;
			unit = NaN;
			return;
		end
		
		%get base value
		baseval = str2num(words(1).str);
		if isnan(baseval)
			disp(strcat("Failed to read base value. (Idx: ", string(index), ", Value string: '", words(1).str, "')."));
			vals = NaN;
			unit = NaN;
			return;
		end
		
		%Get multiplier
		muc = char(words(2).str);
		mult = 1;
		unitStart = 2;
		if muc(1) == 'f'
			mult = 1e-15;
		elseif muc(1) == 'p'
			mult = 1e-12;
		elseif muc(1) == 'n'
			mult = 1e-9;
		elseif muc(1) == 'u' %TODO: what is mu character is sent?
			mult = 1e-6;
		elseif muc(1) == 'm'
			mult = 1e-3;
		elseif muc(1) == 'K' || muc(1) == 'k'
			mult = 1e3;
		elseif muc(1) == 'M' ||(length(muc) >= 3 && muc(1:3) == 'meg')
			mult = 1e6;
			if length(muc) >= 3 && muc(1:3) == 'meg'
				unitStart = 4;
			end
		elseif muc(1) == 'G'
			mult = 1e9;
		elseif muc(1) == 'T'
			mult = 1e12;
		elseif muc(1) == 'E'
			mult = 1e15;
		else
			unitStart = 1;
		end
		
		%Get unit string
		unit = string(muc(unitStart:end));
		
		%Check units match
		if isFirst
			lastUnit = unit;
			isFirst = false;
		else
			if lastUnit ~= unit
				disp(strcat("Error units do not match. (Idx: ", string(index) , ", Unit: '", unit , "', Prev. Unit: '", lastUnit , "')."));
				vals = NaN;
				unit = NaN;
				return;
			end
		end
		
		%Add to list of values
		if isempty(vals)
			vals = baseval * mult;
		else
			vals(end+1) = baseval * mult;
		end
		
		
	end

end